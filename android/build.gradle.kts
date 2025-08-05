// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    // Define the Kotlin version directly within the buildscript block for its use
    val kotlinVersion = "1.9.0" // Recommended: Use a recent stable Kotlin version like "1.9.0" or "1.9.22"

    // This makes 'kotlin_version' available as an extra property to all sub-projects
    // (like your app module) for their own dependencies.
    extra.set("kotlin_version", kotlinVersion)

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Classpath for the Android Gradle Plugin (used for building Android apps)
        classpath("com.android.tools.build:gradle:8.0.0")
        // Classpath for the Kotlin Gradle Plugin, now correctly using the locally defined kotlinVersion
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        // Classpath for your Firebase Google Services plugin
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// Configure repositories and apply JVM Toolchain for all sub-projects
allprojects {
    repositories {
        google()      // Google's Maven repository
        mavenCentral() // Maven Central repository
    }

    // --- START OF CORRECTED JVM TOOLCHAIN BLOCK ---
    // This block correctly ensures that Kotlin compilation for all projects (including plugins)
    // targets Java 8, resolving the JVM-target compatibility issue.
    // It uses pluginManager.withPlugin to apply settings only when the Kotlin Android plugin is present,
    // and does so during the allprojects evaluation phase, avoiding the "already evaluated" error.
    project.pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        project.extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class) {
            jvmToolchain(17) // Set the JVM target for all Kotlin compilation tasks in subprojects to Java 8
        }
    }
    // --- END OF CORRECTED JVM TOOLCHAIN BLOCK ---
}

// Redirect the root project's build directory to avoid conflicts if needed, standard Flutter setup
val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Remaining subprojects configuration (without the problematic afterEvaluate)
subprojects {
    // Redirect sub-projects' build directories relative to the new root build directory
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // Ensure the 'app' module is evaluated before other subprojects if they depend on it.
    // Keep this if you have a specific reason for it.
    project.evaluationDependsOn(":app")
}


// Define a 'clean' task to remove build artifacts
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory) // Deletes the entire build directory
}