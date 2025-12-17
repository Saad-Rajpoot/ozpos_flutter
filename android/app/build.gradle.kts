plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ozpos_flutter"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        languageVersion = "1.9"
        apiVersion = "1.9"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ozpos_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Signing configurations
    signingConfigs {
        // Load keystore properties from keystore.properties file
        // Create this file in android/ directory with your signing credentials
        // See keystore.properties.example for format
        val keystorePropertiesFile = rootProject.file("keystore.properties")
        val keystoreProperties = java.util.Properties()
        
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config if available, otherwise fall back to debug
            // SECURITY: Always use release signing for production builds
            signingConfig = if (signingConfigs.findByName("release") != null) {
                signingConfigs.getByName("release")
            } else {
                // Fallback to debug for development - REMOVE THIS IN PRODUCTION
                signingConfigs.getByName("debug")
            }
            
            // Enable code minification and obfuscation
            isMinifyEnabled = true
            
            // Enable resource shrinking (removes unused resources)
            isShrinkResources = true
            
            // ProGuard rules for code obfuscation and optimization
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Disable debug features in release builds
            isDebuggable = false
            
            // Optimize APK
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            renderscriptOptimLevel = 3
        }
        
        debug {
            // Debug builds remain unchanged for development
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}
