tasks.register<Exec>("elmMake") {
    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/Main.elm", "--output", jsPath )
}

tasks.register<Copy>("copyIndexHtml") {
    from("src/index.html")
    into("$projectDir/build/")
}

tasks.register<Delete>("clean") {
    delete.add("elm/elm-stuff/0.19.0")
    delete.add("elm/elm-stuff/generated-code")
    delete.add("build")
}

tasks.register<Copy>("copyElmApp") {
    val elmMake by tasks.getting
    val copyIndexHtml by tasks.getting

    val processResources by project(":backend").tasks.existing(ProcessResources::class)

    from(elmMake.outputs)
    from(copyIndexHtml.outputs)
    into(processResources.get().destinationDir.toString() + "/public")

    dependsOn(":frontend:elmMake")
    dependsOn(":frontend:copyIndexHtml")
}

project(":backend") {
    tasks.named("processResources") {
        dependsOn(":frontend:copyElmApp")
    }
}