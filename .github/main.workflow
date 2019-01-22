workflow "SMosquitto Linux Build" {
  on = "push"
  resolves = ["Swift Package Test"]
}

action "Swift Package Build" {
  uses = "diejmon/SMosquitto@master"
  runs = "swift build --configuration release"
}

action "Swift Package Test" {
  uses = "diejmon/SMosquitto@master"
  runs = "swift test --parallel"
  needs = ["Swift Package Build"]
  secrets = ["TEST_MQTT_SERVER", "TEST_MQTT_PORT", "TEST_MQTT_USERNAME", "TEST_MQTT_PASSWORD"]
}
