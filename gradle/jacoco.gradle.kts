apply(plugin = "jacoco")

val sourceSets = the<SourceSetContainer>()

// Example how to configure plugin
//extensions.configure<JacocoPluginExtension> {
//    println(toolVersion)
//    toolVersion = "0.8.4"
//}

tasks.named<JacocoReport>("jacocoTestReport") {
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

tasks.named<JacocoCoverageVerification>("jacocoTestCoverageVerification") {
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
