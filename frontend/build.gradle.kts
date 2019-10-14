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



tasks.register<Copy>("copyElmApp") {
    val elmMake by tasks.getting

    val processResources by project(":backend").tasks.existing(ProcessResources::class)

    println("Output: " + processResources.get().destinationDir)
    from(elmMake.outputs)
    into(processResources.get().destinationDir)

    dependsOn(":frontend:elmMake")
}

project(":backend") {
    tasks.named("processResources") {
        dependsOn(":frontend:copyElmApp")
    }
}