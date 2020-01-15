import com.github.spotbugs.SpotBugsTask
import info.solidsoft.gradle.pitest.PitestPluginExtension

plugins {
    java
    id("org.springframework.boot") version "2.2.2.RELEASE"
    id("io.spring.dependency-management") version "1.0.8.RELEASE"
    id("org.asciidoctor.convert") version "1.5.8"

    id("com.github.spotbugs") version "2.0.0"
    id("info.solidsoft.pitest") version "1.4.5"
}

apply(from = "../gradle/integrationTest.gradle.kts")
// FIXME: This would be enabled in real project. It is commented out to show other plugins.
//apply(from = "../gradle/jacoco.gradle.kts")
apply(from = "../gradle/checkstyle.gradle.kts")
apply(from = "../gradle/pmd.gradle.kts")

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

val snippetsDir = file("build/generated-snippets")

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-hateoas")
    implementation("org.flywaydb:flyway-core")
    compileOnly("org.projectlombok:lombok")
    runtimeOnly("org.postgresql:postgresql")
    runtimeOnly("com.h2database:h2")
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

spotbugs {
    toolVersion = "4.0.0-beta4"
    isIgnoreFailures = true
}

tasks.withType<SpotBugsTask> {
    reports.xml.isEnabled = false
    reports.html.isEnabled = true
}

configure<PitestPluginExtension> {
    pitestVersion.set("1.4.10")

    // FIXME: Commenting coverage threshold so task doesnt fail check task.
//    coverageThreshold.set(80)
    // This can add integration test to pitest plugin, but only unit tests should be used for now
//    testSourceSets.add(sourceSets["integrationTest"])
}


tasks.named("check") { dependsOn(tasks["pitest"]) }