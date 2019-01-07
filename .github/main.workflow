workflow "SMosquitto Linux Build" {
  on = "push"
  resolves = ["Swift Package Build"]
}
action "Swift Package Fetch" {
  uses = "https://github.com/diejmon/SMosquitto.git@master"
  runs = "swift package resolve"
}
action "Swift Package Build" {
  uses = "https://github.com/diejmon/SMosquitto.git@master"
  needs = ["Swift Package Fetch"]
  runs = "swift build"
}
