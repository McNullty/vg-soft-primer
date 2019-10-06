apply(plugin = "checkstyle")

configure<CheckstyleExtension> {
    toolVersion = "8.25"
}

tasks.withType<Checkstyle>().configureEach {
    reports {
        xml.isEnabled = false
        html.isEnabled = true
    }
}
