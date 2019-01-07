workflow "SMosquitto Linux Build" {
  on = "push"
  resolves = ["Swift Package Build"]
}
action "Swift Package Build" {
  uses = "diejmon/SMosquitto@master"
  runs = "swift build"
}
