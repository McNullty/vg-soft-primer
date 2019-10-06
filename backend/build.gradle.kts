plugins {
    java
    idea
    jacoco
    id("org.springframework.boot") version "2.1.9.RELEASE"
    id("io.spring.dependency-management") version "1.0.8.RELEASE"
    id("org.asciidoctor.convert") version "1.5.8"
}

apply(from = "../gradle/integrationTest.gradle.kts")

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
    testImplementation ("org.springframework.restdocs:spring-restdocs-mockmvc")
}

tasks.test {
    outputs.dir(snippetsDir)
}

tasks.asciidoctor {
    inputs.dir(snippetsDir)
    dependsOn(tasks.test)
}

tasks.jacocoTestReport {
    reports {
        csv.isEnabled = false
        html.isEnabled = true
        xml.isEnabled = false

        html.destination = file("${buildDir}/reports/jacocoAllTestHtml")
    }

    executionData(tasks["test"], tasks["integrationTest"])
    dependsOn(tasks["test"], tasks["integrationTest"])
}

task<JacocoReport>("jacocoIntegrationTestReport") {
    description = "Generates code coverage report for integrationTest task"
    group = "verification"

    reports {
        csv.isEnabled = false
        html.isEnabled = true
        xml.isEnabled = false

        html.destination = file("${buildDir}/reports/jacocoIntegrationTestHtml")
    }

    executionData(tasks["integrationTest"])
    sourceSets(sourceSets.getByName("main"))
    dependsOn(tasks["integrationTest"])
}

task<JacocoReport>("jacocoUnitTestReport") {
    description = "Generates code coverage report only for test task"
    group = "verification"

    reports {
        csv.isEnabled = false
        html.isEnabled = true
        xml.isEnabled = false

        html.destination = file("${buildDir}/reports/jacocoUnitTestHtml")
    }

    executionData(tasks["test"])
    sourceSets(sourceSets.getByName("main"))
    dependsOn(tasks["test"])
}



tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = "0.8".toBigDecimal()
            }
        }
    }
    executionData(tasks["test"], tasks["integrationTest"])
    sourceSets(sourceSets.getByName("main"))
    dependsOn(tasks["test"], tasks["integrationTest"])
}

tasks.named("check") { dependsOn(tasks["jacocoTestCoverageVerification"]) }
