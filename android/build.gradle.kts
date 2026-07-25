allprojects {
    repositories {
        maven(url = "https://maven.aliyun.com/repository/google")
        maven(url = "https://maven.aliyun.com/repository/central")
        maven(url = "https://maven.aliyun.com/repository/public")
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Plugins such as super_native_extensions still ship compileSdk 31 on pub.dev,
// but AndroidX 1.13+ requires compileSdk >= 34. Force libraries to match the app.
// Must run before evaluationDependsOn(":app"), and handle already-evaluated projects.
subprojects {
    fun bumpLibraryCompileSdk() {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
            if ((compileSdk ?: 0) < 34) {
                compileSdk = 36
            }
        }
    }
    if (state.executed) {
        bumpLibraryCompileSdk()
    } else {
        afterEvaluate { bumpLibraryCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
