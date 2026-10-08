#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds the home-screen widget (local habits stage 4, plan-local-habits §4
# "iOS") to apps/game/ios/Runner.xcodeproj and wires what it needs:
#
# - the `NestyWidget` WidgetKit app-extension target in the nine
#   configurations (Debug-/Profile-/Release-<flavor>), bundle ids
#   `<app id>.widget`, iOS 14.0, Swift 5, its Info.plist, entitlements and
#   xcconfig, the generated asset catalog and <lang>.lproj strings, and the
#   app's Fredoka and Nunito fonts by reference (never copied);
# - "Embed Foundation Extensions" in Runner, ordered before "Thin Binary"
#   (Xcode 15's build cycle);
# - the App Groups (`APP_GROUP_ID`) and URL schemes (`APP_URL_SCHEME`) per
#   flavor in both targets, Runner.entitlements, and `DEBUG` in Runner's
#   Debug Swift conditions (the channel's debug-only `readBack`/`storeInfo`);
# - NestyWidgetStore.swift in Runner (the channel's store), and
#   NestyWidgetCore.swift, NestyWidgetStore.swift, NestyWidgetCoreTests.swift
#   and the Dart side's snapshot goldens (by reference) in RunnerTests.
#
# Idempotent: a second run changes nothing. Uses the xcodeproj gem that
# CocoaPods ships. The extension has no pods (it isn't in the Podfile).
#
#   ruby tools/ios/add_widget_target.rb           # apply
#   ruby tools/ios/add_widget_target.rb --check   # exit 1 when a run would change the project

require 'fileutils'
require 'tmpdir'
require 'xcodeproj'

ROOT = File.expand_path('../..', __dir__)
IOS = File.join(ROOT, 'apps', 'game', 'ios')
PROJECT_PATH = File.join(IOS, 'Runner.xcodeproj')

WIDGET = 'NestyWidget'
EMBED_PHASE = 'Embed Foundation Extensions'

# The flavors' ids (CLAUDE.md "Flavors"; stage 4 contract §2 and §4).
FLAVORS = {
  'dev' => { app_id: 'com.futrix.nesty.dev', group: 'group.com.futrix.nesty.dev', scheme: 'nesty-dev' },
  'stg' => { app_id: 'com.futrix.nesty.stg', group: 'group.com.futrix.nesty.stg', scheme: 'nesty-stg' },
  'prod' => { app_id: 'com.futrix.nesty', group: 'group.com.futrix.nesty', scheme: 'nesty' }
}.freeze
KINDS = %w[Debug Profile Release].freeze
CONFIGS = KINDS.flat_map { |kind| FLAVORS.keys.map { |flavor| "#{kind}-#{flavor}" } }.freeze

WIDGET_SOURCES = %w[NestyWidget.swift NestyWidgetViews.swift NestyWidgetStyle.swift NestyWidgetCore.swift
                    NestyWidgetStore.swift].freeze
WIDGET_FILES = %w[Info.plist NestyWidget.entitlements NestyWidget.xcconfig].freeze
# Info.plist UIAppFonts lists the same files (design spec §9).
FONTS = %w[Fredoka-Bold.ttf Nunito-Bold.ttf Nunito-ExtraBold.ttf].freeze

def fail!(message)
  warn "add_widget_target: #{message}"
  exit 2
end

def check_inputs
  (WIDGET_SOURCES + WIDGET_FILES + ['Assets.xcassets']).each do |name|
    fail!("missing apps/game/ios/#{WIDGET}/#{name}") unless File.exist?(File.join(IOS, WIDGET, name))
  end
  FONTS.each do |font|
    fail!("missing apps/game/assets/fonts/#{font}") unless File.exist?(File.join(IOS, '..', 'assets', 'fonts', font))
  end
  fail!('missing apps/game/ios/Runner/Runner.entitlements') unless File.exist?(File.join(IOS, 'Runner', 'Runner.entitlements'))
  unless File.exist?(File.join(IOS, 'RunnerTests', 'NestyWidgetCoreTests.swift'))
    fail!('missing apps/game/ios/RunnerTests/NestyWidgetCoreTests.swift')
  end
  fail!('no widget strings: run dart run nesty_tools:gen_widget_strings') if languages.empty?
  fail!('no snapshot goldens in apps/game/test/fixtures') if goldens.empty?
end

# The <lang>.lproj folders gen_widget_strings writes.
def languages
  Dir.glob(File.join(IOS, WIDGET, '*.lproj', 'Localizable.strings'))
     .map { |path| File.basename(File.dirname(path), '.lproj') }
     .sort
end

# The Dart side's snapshot goldens (apps/game/test/fixtures), by name.
def goldens
  Dir.glob(File.join(IOS, '..', 'test', 'fixtures', 'widget_snapshot_v1*.json')).map { |p| File.basename(p) }.sort
end

def target_named(project, name)
  project.targets.find { |t| t.name == name }
end

def child_group(parent, path)
  parent.children.find { |c| c.isa == 'PBXGroup' && c.path == path } || parent.new_group(nil, path)
end

def child_group_named(parent, name)
  parent.children.find { |c| c.isa == 'PBXGroup' && c.name == name && c.path.nil? } || parent.new_group(name)
end

def file_ref(group, path, source_tree = :group, name: nil)
  ref = group.files.find { |f| f.path == path }
  ref ||= group.new_reference(path, source_tree)
  ref.name = name if name && ref.name != name
  ref
end

def add_to_phase(phase, ref)
  phase.add_file_reference(ref, true) unless phase.files_references.include?(ref)
end

def sorted(settings)
  settings.sort_by { |key, _| key }.to_h
end

def flavor_of(config_name)
  flavor = config_name.split('-', 2).last
  FLAVORS.fetch(flavor) { fail!("unexpected configuration #{config_name}") }
  flavor
end

def runner_settings(runner, name)
  config = runner.build_configuration_list.build_configurations.find { |c| c.name == name }
  fail!("Runner has no #{name} configuration") unless config
  config
end

# Runner: the App Group, the scheme, the entitlements, DEBUG for Swift.
def configure_runner(runner)
  CONFIGS.each do |name|
    flavor = flavor_of(name)
    ids = FLAVORS[flavor]
    config = runner_settings(runner, name)
    settings = config.build_settings
    if settings['PRODUCT_BUNDLE_IDENTIFIER'] != ids[:app_id]
      fail!("Runner #{name} is #{settings['PRODUCT_BUNDLE_IDENTIFIER']}, expected #{ids[:app_id]}")
    end
    settings['APP_GROUP_ID'] = ids[:group]
    settings['APP_URL_SCHEME'] = ids[:scheme]
    settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
    settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG $(inherited)' if name.start_with?('Debug-')
    config.build_settings = sorted(settings)
  end
end

def widget_settings(runner, name)
  flavor = flavor_of(name)
  ids = FLAVORS[flavor]
  app = runner_settings(runner, name).build_settings
  settings = {
    'APP_DISPLAY_NAME' => app['APP_DISPLAY_NAME'],
    'APP_GROUP_ID' => ids[:group],
    'APP_URL_SCHEME' => ids[:scheme],
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
    'CODE_SIGN_ENTITLEMENTS' => "#{WIDGET}/#{WIDGET}.entitlements",
    'CODE_SIGN_STYLE' => 'Automatic',
    'CURRENT_PROJECT_VERSION' => '$(FLUTTER_BUILD_NUMBER)',
    'DEVELOPMENT_TEAM' => app['DEVELOPMENT_TEAM'],
    'GENERATE_INFOPLIST_FILE' => 'NO',
    'INFOPLIST_FILE' => "#{WIDGET}/Info.plist",
    'IPHONEOS_DEPLOYMENT_TARGET' => '14.0',
    'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks'],
    'MARKETING_VERSION' => '$(FLUTTER_BUILD_NAME)',
    'NESTY_FLAVOR' => flavor,
    'PRODUCT_BUNDLE_IDENTIFIER' => "#{ids[:app_id]}.widget",
    'PRODUCT_NAME' => '$(TARGET_NAME)',
    'SKIP_INSTALL' => 'YES',
    'SWIFT_VERSION' => '5.0',
    'TARGETED_DEVICE_FAMILY' => '1,2'
  }
  if name.start_with?('Debug-')
    settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG $(inherited)'
    settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  end
  settings.compact
end

def widget_target(project, runner, xcconfig)
  target = target_named(project, WIDGET)
  unless target
    target = project.new(Xcodeproj::Project::Object::PBXNativeTarget)
    project.targets << target
    target.name = WIDGET
    target.product_name = WIDGET
    target.product_type = Xcodeproj::Constants::PRODUCT_TYPE_UTI[:app_extension]
    list = project.new(Xcodeproj::Project::Object::XCConfigurationList)
    list.default_configuration_is_visible = '0'
    list.default_configuration_name = 'Release-prod'
    target.build_configuration_list = list
    target.product_reference = project.products_group.new_product_ref_for_target(WIDGET, :app_extension)
    [Xcodeproj::Project::Object::PBXSourcesBuildPhase,
     Xcodeproj::Project::Object::PBXFrameworksBuildPhase,
     Xcodeproj::Project::Object::PBXResourcesBuildPhase].each { |phase| target.build_phases << project.new(phase) }
  end
  list = target.build_configuration_list
  CONFIGS.each do |name|
    config = list.build_configurations.find { |c| c.name == name }
    unless config
      config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      config.name = name
      list.build_configurations << config
    end
    config.base_configuration_reference = xcconfig
    desired = sorted(widget_settings(runner, name))
    config.build_settings = desired unless config.build_settings == desired
  end
  list.build_configurations.reject { |c| CONFIGS.include?(c.name) }.each(&:remove_from_project)
  target
end

# "Embed Foundation Extensions" holds the .appex, before "Thin Binary".
def embed_widget(project, runner, widget)
  phases = runner.build_phases
  embed = phases.find { |p| p.isa == 'PBXCopyFilesBuildPhase' && p.name == EMBED_PHASE }
  unless embed
    embed = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
    embed.name = EMBED_PHASE
    embed.symbol_dst_subfolder_spec = :plug_ins
    embed.dst_path = ''
    phases << embed
  end
  thin = phases.find { |p| p.isa == 'PBXShellScriptBuildPhase' && p.name == 'Thin Binary' }
  fail!('Runner has no "Thin Binary" phase') unless thin
  if phases.index(embed) > phases.index(thin)
    phases.delete(embed)
    phases.insert(phases.index(thin), embed)
  end
  unless embed.files_references.include?(widget.product_reference)
    build_file = embed.add_file_reference(widget.product_reference, true)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
  end
  runner.add_dependency(widget) unless runner.dependencies.any? { |d| d.target == widget }
end

def apply(project)
  runner = target_named(project, 'Runner') || fail!('no Runner target')
  tests = target_named(project, 'RunnerTests') || fail!('no RunnerTests target')
  main = project.main_group

  # The widget's group and files.
  group = child_group(main, WIDGET)
  refs = WIDGET_SOURCES.to_h { |name| [name, file_ref(group, name)] }
  WIDGET_FILES.each { |name| file_ref(group, name) }
  assets = file_ref(group, 'Assets.xcassets')
  strings = group.children.find { |c| c.isa == 'PBXVariantGroup' && c.name == 'Localizable.strings' } ||
            group.new_variant_group('Localizable.strings')
  languages.each { |lang| file_ref(strings, "#{lang}.lproj/Localizable.strings", name: lang) }
  strings.files.reject { |f| languages.include?(f.name) }.each(&:remove_from_project)
  fonts_group = child_group_named(group, 'Fonts')
  fonts = FONTS.map { |font| file_ref(fonts_group, "../assets/fonts/#{font}", :project, name: font) }

  xcconfig = group.files.find { |f| f.path == "#{WIDGET}.xcconfig" }
  widget = widget_target(project, runner, xcconfig)
  WIDGET_SOURCES.each { |name| add_to_phase(widget.source_build_phase, refs[name]) }
  add_to_phase(widget.resources_build_phase, assets)
  add_to_phase(widget.resources_build_phase, strings)
  fonts.each { |ref| add_to_phase(widget.resources_build_phase, ref) }

  regions = project.root_object.known_regions
  languages.each { |lang| regions << lang unless regions.include?(lang) }

  # Runner: the channel's store, the entitlements, the embed and settings.
  runner_group = main.children.find { |c| c.isa == 'PBXGroup' && c.path == 'Runner' } || fail!('no Runner group')
  file_ref(runner_group, 'Runner.entitlements')
  add_to_phase(runner.source_build_phase, refs['NestyWidgetStore.swift'])
  embed_widget(project, runner, widget)
  configure_runner(runner)

  # RunnerTests: the core, the store, their tests and the goldens.
  tests_group = main.children.find { |c| c.isa == 'PBXGroup' && c.path == 'RunnerTests' } || fail!('no RunnerTests group')
  add_to_phase(tests.source_build_phase, file_ref(tests_group, 'NestyWidgetCoreTests.swift'))
  add_to_phase(tests.source_build_phase, refs['NestyWidgetCore.swift'])
  add_to_phase(tests.source_build_phase, refs['NestyWidgetStore.swift'])
  fixtures = child_group_named(tests_group, 'Fixtures')
  goldens.each do |name|
    ref = file_ref(fixtures, "../test/fixtures/#{name}", :project, name: name)
    add_to_phase(tests.resources_build_phase, ref)
  end
end

def pbxproj_after_apply
  project = Xcodeproj::Project.open(PROJECT_PATH)
  apply(project)
  Dir.mktmpdir do |dir|
    out = File.join(dir, 'Runner.xcodeproj')
    project.save(out)
    File.read(File.join(out, 'project.pbxproj'))
  end
end

check_inputs
pbxproj_path = File.join(PROJECT_PATH, 'project.pbxproj')
before = File.read(pbxproj_path)
after = pbxproj_after_apply

if ARGV.include?('--check')
  if before == after
    puts 'add_widget_target: up to date'
    exit 0
  end
  warn 'add_widget_target: Runner.xcodeproj is out of date; run ruby tools/ios/add_widget_target.rb'
  exit 1
end

if before == after
  puts 'add_widget_target: no change'
else
  File.write(pbxproj_path, after)
  puts 'add_widget_target: updated apps/game/ios/Runner.xcodeproj'
end
