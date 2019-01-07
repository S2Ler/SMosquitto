import cmosquitto

public struct SMosquittoVersion: Hashable {
  public let major: Int32
  public let minor: Int32
  public let revision: Int32
  private let uniqueVersionNumber: Int32

  public init() {
    var major: Int32 = 0
    var minor: Int32 = 0
    var revision: Int32 = 0
    self.uniqueVersionNumber = mosquitto_lib_version(&major, &minor, &revision)
    self.major = major
    self.minor = minor
    self.revision = revision
  }

  public var hashValue: Int {
    return Int(uniqueVersionNumber)
  }

  public static func == (lhs: SMosquittoVersion, rhs: SMosquittoVersion) -> Bool {
    return lhs.uniqueVersionNumber == rhs.uniqueVersionNumber
  }
}
