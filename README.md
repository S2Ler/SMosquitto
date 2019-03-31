# SMoquitto

Swift 5.0, macOS, Linux.

A thin Swift wrapper for [libmosquitto](https://github.com/eclipse/mosquitto/tree/master/lib). Supports macOS and Linux.

## Installation

Use [SPM](https://swift.org/package-manager/).

Sample `Package.swift`
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "ProjectName",
  products: [
    .executable(name: "ProjectName", targets: ["ProjectName"]),
    ],
  dependencies: [
    .package(url: "https://github.com/diejmon/SMosquitto.git", .upToNextMinor(from: "1.4.0")),
  ],
  targets: [
    .target(
      name: "ProjectName",
      dependencies: ["SMosquitto"]),
  ],
  swiftLanguageVersions: [.v5]
)
```

## Usage

```swift
import SMosquitto

SMosquitto.initialize()
let smosquitto = SMosquitto(id: "An ID", cleanSession: true)

try smosquitto.setLoginInformation(username: "username", password: "password")
try smosquitto.connect(host: "hostname", port: 1883, keepalive: true)

smosquitto.onConnect = { response in
      do {
        // Subscribe for topics once connected to server. 
        try smosquitto.subscribe(subscriptionPattern: "atopic", qos: .atleastOnce)
      }
      catch {
        // an error happened
      }
}

smosquitto.onMessage = { message in
  // Do something with received message
}

/// Start async loop
try smosquitto.loopForever(timeout: .interval(45))
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Please make sure to update tests as appropriate.
