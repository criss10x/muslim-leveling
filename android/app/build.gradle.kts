import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    id("com.google.gms.google-services")
}

apply(plugin = "org.jetbrains.kotlin.android")


val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

val useReleaseKeystore = keystoreProperties.getProperty("storeFile")?.let { rootProject.file(it).exists() } == true

android {
    namespace = "id.muslimleveling.muslim_leveling"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "id.muslimleveling.muslim_leveling"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (useReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ponytail: fail-fast kalau keystore release tidak ada — jangan pernah
            // silent-fallback ke debug signing di build release (Play Store akan tolak).
            if (!useReleaseKeystore) {
                throw GradleException("Release build tanpa keystore: key.properties atau storeFile tidak ditemukan.")
            }
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// package_info_plus (transitive via sentry_flutter) unused. Under AGP>=9 its KGP
// is skipped and PackageInfoPlugin.kt is not compiled, but GeneratedPluginRegistrant
// still references it → cannot find symbol. Strip dead registration before javac.
// ponytail: remove when package_info_plus fully on Flutter built-in Kotlin registry.
afterEvaluate {
    tasks.matching {
        it.name.startsWith("compile") && it.name.endsWith("JavaWithJavac")
    }.configureEach {
        doFirst {
            val regFile = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
            if (regFile.exists()) {
                val cleaned = regFile.readText().replace(
                    Regex("""\s*try\s*\{[^}]*PackageInfoPlugin[^}]*\}\s*catch[^}]*\}\s*"""),
                    "",
                )
                regFile.writeText(cleaned)
            }
        }
    }
}
