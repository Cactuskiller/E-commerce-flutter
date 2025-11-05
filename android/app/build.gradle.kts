plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.e_commerce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17   // ✅ Upgrade to 17 (recommended)
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // ✅ Match Kotlin with Java 17
    }

    defaultConfig {
        applicationId = "com.example.e_commerce"
        minSdk = 21                                    // ✅ OneSignal requires at least 21
        targetSdk = 34                                 // ✅ Modern target
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true                         // ✅ Prevent "Too many methods" issue
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
