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
  runs = "swift test --generate-linuxmain --parallel --sanitize=thread"
  needs = ["Swift Package Build"]
}
