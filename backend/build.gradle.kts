plugins {
    java
    idea
    id("org.springframework.boot") version "2.1.9.RELEASE"
    id("io.spring.dependency-management") version "1.0.8.RELEASE"
    id("org.asciidoctor.convert") version "1.5.8"
}

group = "hr.vgsoft"

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

repositories {
    mavenCentral()
}

// Integration test configuration
sourceSets {
    create("integrationTest") {
        compileClasspath += sourceSets.main.get().output
        runtimeClasspath += sourceSets.main.get().output
    }
}

val integrationTestImplementation: Configuration by configurations.getting {
    extendsFrom(configurations.implementation.get())
}

configurations["integrationTestRuntimeOnly"].extendsFrom(configurations.runtimeOnly.get())
// Integration test configuration end

idea {
    module {
        testSourceDirs = testSourceDirs + sourceSets["integrationTest"].java.srcDirs
        testResourceDirs = testResourceDirs + sourceSets["integrationTest"].resources.srcDirs
        scopes["TEST"]!!["plus"]!!.add(configurations["integrationTestCompile"])
    }
}

val snippetsDir = file("build/generated-snippets")

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation ("org.springframework.boot:spring-boot-starter-web")
    compileOnly ("org.projectlombok:lombok")
    annotationProcessor ("org.springframework.boot:spring-boot-configuration-processor")
    annotationProcessor ("org.projectlombok:lombok")
    testImplementation ("org.springframework.boot:spring-boot-starter-test")
    integrationTestImplementation ("org.springframework.boot:spring-boot-starter-test")
    testImplementation ("org.springframework.restdocs:spring-restdocs-mockmvc")
}

tasks.test {
    outputs.dir(snippetsDir)
}

val integrationTestTask = task<Test>("integrationTest") {
    description = "Runs the integration tests"
    group = "verification"

    testClassesDirs = sourceSets["integrationTest"].output.classesDirs
    classpath = sourceSets["integrationTest"].runtimeClasspath

    shouldRunAfter("test")

}
tasks.check { dependsOn(integrationTestTask) }

tasks.asciidoctor {
    inputs.dir(snippetsDir)
    dependsOn(tasks.test)
}
