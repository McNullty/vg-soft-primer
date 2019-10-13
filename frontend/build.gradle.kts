tasks.register<Exec>("elmMake") {
    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/Main.elm", "--output", jsPath )
}

tasks.register<Delete>("clean") {
    delete.add("elm/elm-stuff/0.19.0")
    delete.add("elm/elm-stuff/generated-code")
    delete.add("build")
}


project(":backend") {
    tasks.named("processResources") {
        dependsOn(":frontend:elmMake")
    }
}