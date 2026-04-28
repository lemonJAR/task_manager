plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        new FileInputStream(keystorePropertiesFile))
}
 
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias'] \
                ?: System.getenv('KEY_ALIAS')
            keyPassword keystoreProperties['keyPassword'] \
                ?: System.getenv('KEY_PASSWORD')
            storeFile keystoreProperties['storeFile'] ?
                file(keystoreProperties['storeFile']) :
                file(System.getenv('KEYSTORE_PATH'))
            storePassword keystoreProperties['storePassword'] \
                ?: System.getenv('STORE_PASSWORD')
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}


flutter {
    source = "../.."
}
