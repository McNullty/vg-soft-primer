plugins {
    id("org.mohme.gradle.elm-plugin") version "3.2.2"
}

elm {
    sourceDir.set(project.file("src"))
    targetModuleName.set("elm.js")
    debug.set(true)
    optimize.set(false)
}