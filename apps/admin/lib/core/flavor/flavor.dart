/// Build flavors. Each has its own entry point (`lib/main_<flavor>.dart`).
/// The admin is web-only, so there are no native flavors; the entry point
/// alone picks the flavor (`flutter run -d chrome -t lib/main_dev.dart`).
enum Flavor { dev, stg, prod }
