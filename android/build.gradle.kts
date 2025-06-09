allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
<<<<<<< HEAD
plugins {

  id("com.google.gms.google-services") version "4.3.15" apply false

}
=======

>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
