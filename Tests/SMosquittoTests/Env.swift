import Foundation

internal enum Env {
  case server
  case port
  case username
  case password

  private var key: String {
    switch self {
    case .server:
      return "TEST_MQTT_SERVER"
    case .port:
      return "TEST_MQTT_PORT"
    case .username:
      return "TEST_MQTT_USERNAME"
    case .password:
      return "TEST_MQTT_PASSWORD"
    }
  }

  public static func get(_ env: Env) -> String {
    guard let value = ProcessInfo.processInfo.environment[env.key] else {
      preconditionFailure("Env variable \(env.key) hasn't been set")
    }

    return value
  }

  public static func get<IntType: FixedWidthInteger>(_ env: Env) -> IntType {
    guard let value = ProcessInfo.processInfo.environment[env.key] else {
      preconditionFailure("Env variable \(env.key) hasn't been set")
    }

    guard let intValue = IntType(value) else {
      preconditionFailure("Can't convert \(value) to Int")
    }
    
    return intValue
  }

}
