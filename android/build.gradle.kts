plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    // ✅ add the version here
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// (optional) keep your custom buildDir relocation
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

// If you are using dependencyResolutionManagement in settings.gradle.kts,
// you can remove this 'allprojects' block. Keeping it is harmless.
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
