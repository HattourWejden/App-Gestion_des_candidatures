pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
<<<<<<< HEAD
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
=======
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
