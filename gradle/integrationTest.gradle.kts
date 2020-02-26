import org.gradle.plugins.ide.idea.model.IdeaModel

apply(plugin = "idea")

val sourceSets = the<SourceSetContainer>()

sourceSets {
    create("integrationTest") {
        compileClasspath += sourceSets["main"].output
        runtimeClasspath += sourceSets["main"].output
    }
}

val integrationTestImplementation: Configuration by configurations.getting {
    extendsFrom(configurations["implementation"])
}

configurations["integrationTestRuntimeOnly"].extendsFrom(configurations["runtimeOnly"])

dependencies {
    integrationTestImplementation ("org.springframework.boot:spring-boot-starter-test")
}

val integrationTestTask = task<Test>("integrationTest") {
    description = "Runs the integration tests"
    group = "verification"

    testClassesDirs = sourceSets["integrationTest"].output.classesDirs
    classpath = sourceSets["integrationTest"].runtimeClasspath

    shouldRunAfter("test")

    useJUnitPlatform()
}
tasks.named("check") { dependsOn(integrationTestTask) }

extensions.configure<IdeaModel> {
    module {
        testSourceDirs = testSourceDirs + sourceSets["integrationTest"].java.srcDirs
        testResourceDirs = testResourceDirs + sourceSets["integrationTest"].resources.srcDirs
        scopes["TEST"]!!["plus"]!!.add(configurations["integrationTestCompile"])
    }
}
