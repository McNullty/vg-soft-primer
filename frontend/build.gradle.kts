tasks.register<Exec>("elmMake") {
    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/Main.elm", "--output", jsPath )
}


//project(":backend") {
//    tasks.named("processResources") {
//        dependsOn(":frontend:elmMake")
////        tasks.register<Copy>("copyFrontend") {
////            from(tasks.getByPath(":frontend:elmMake").outputs)
////            into("public")
////        }
//
//    }
//}