plugins {
    id("com.android.library")
}

group = "com.omert.esp_softap_provisioning"
version = "1.0-SNAPSHOT"

android {
    namespace = "com.omert.esp_softap_provisioning"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 24
    }
}
