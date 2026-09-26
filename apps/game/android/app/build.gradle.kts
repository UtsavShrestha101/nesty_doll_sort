plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.futrix.nesty"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        // The flavors below set app_name with resValue(). Turn the feature on
        // explicitly so a change to AGP's default can't silently drop the label.
        resValues = true
    }

    defaultConfig {
        // Flavors add .dev / .stg to this, so dev, stg and prod can be
        // installed side by side.
        applicationId = "com.futrix.nesty"
        // Spec §0: minimum Android 7 (API 24). Pinned here, not taken from
        // flutter.minSdkVersion, so a Flutter SDK upgrade can't change the
        // supported devices without anyone noticing.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Each flavor matches an entry point in lib/ and a Firebase project (M4):
    //   flutter run --flavor dev  -t lib/main_dev.dart
    //   flutter run --flavor stg  -t lib/main_stg.dart
    //   flutter run --flavor prod -t lib/main_prod.dart
    // The iOS schemes dev / stg / prod use the same names.
    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "[DEV] Nesty")
        }
        create("stg") {
            dimension = "default"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "[STG] Nesty")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "Nesty")
        }
    }

    buildTypes {
        release {
            // TODO(M8): Sign release builds with the upload key. Load it from an
            // untracked android/key.properties (storeFile, storePassword,
            // keyAlias, keyPassword) and never commit the keystore or passwords.
            // .gitignore already excludes key.properties, *.jks and *.keystore.
            // Until then, release builds use the debug keys so
            // `flutter run --release --flavor <f>` works. Spec §18 M8.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
