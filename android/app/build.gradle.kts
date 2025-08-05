plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.getsetgo" // Changed namespace to match Firebase
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // --- START OF CHANGES FOR DESUGARING (Kotlin DSL Syntax) ---
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true // Kotlin DSL uses 'is' prefix for boolean properties
        // Set compatibility to Java 8
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // --- END OF CHANGES FOR DESUGARING ---
    }

    kotlinOptions {
        // Set JVM target to 1.8 for compatibility with desugaring
        jvmTarget = "1.8" // Kotlin DSL uses double quotes for string literals
    }

    defaultConfig {
        // Corrected the applicationId to match Firebase
        applicationId = "com.getsetgo"
        minSdk = 23 // minSdk 23 is fine for desugaring
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // For multi-dex support if your app grows very large (optional, but often needed with desugaring)
        multiDexEnabled = true // Explicitly enable multidex
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // NOTE: It is recommended to use a separate release signing config
            // for production builds instead of the debug key.
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Correct way to access kotlin_version from the root project's extra properties in Kotlin DSL
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:${rootProject.extra["kotlin_version"]}")

    // Add the desugaring library dependency (Kotlin DSL syntax for string literal)
    // This version is now correctly set to 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Other dependencies might go here as well, if any are specifically for Android Gradle
}
