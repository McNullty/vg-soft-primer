apply(plugin = "pmd")

configure<PmdExtension> {
    toolVersion = "6.18.0"
    isIgnoreFailures = true
}

tasks.withType<Pmd> {
    reports {
        xml.isEnabled = false
        html.isEnabled = true
    }
}