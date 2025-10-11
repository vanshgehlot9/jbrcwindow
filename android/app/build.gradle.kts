plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.jbrc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.jbrc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required for flutter_local_notifications (and some other libs)
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions { jvmTarget = "17" }

    signingConfigs {
        // built-in debug keystore
        getByName("debug")

        // TODO: set up a real release keystore when you’re ready to sign
        create("release") {
            // storeFile = file("/abs/path/your-release-keystore.jks")
            // storePassword = "..."
            // keyAlias = "..."
            // keyPassword = "..."
        }
    }

    buildTypes {
        getByName("debug") {
            // Keep the SAME applicationId so Firebase JSON matches
            // applicationIdSuffix = ".debug"   // <-- removed on purpose
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Add the desugaring JDK libs (KTS-safe way)
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.1.2")
    // implementation("org.jetbrains.kotlin:kotlin-stdlib") // not strictly needed
}
