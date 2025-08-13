plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ Google 서비스 플러그인 추가
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app" // Firebase 콘솔 등록한 패키지명과 동일해야 함
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app" // 🔹 이 값이 Firebase 등록 앱 패키지명과 정확히 일치해야 함
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // ✅ Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // ✅ Google Analytics (선택)
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Firebase Auth (구글 로그인 용)
    implementation("com.google.firebase:firebase-auth")

    // ✅ Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
