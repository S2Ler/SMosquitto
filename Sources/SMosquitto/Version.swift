import cmosquitto

public extension SMosquitto {
  public struct Version: Hashable, Codable {
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

    private init(major: Int32, minor: Int32, revision: Int32, uniqueVersionNumber: Int32) {
      self.major = major
      self.minor = minor
      self.revision = revision
      self.uniqueVersionNumber = uniqueVersionNumber
    }

    internal static func compiledWithVersion() -> Version {
      let LIBMOSQUITTO_VERSION_NUMBER: Int32
        = LIBMOSQUITTO_MAJOR * 1000000
          + LIBMOSQUITTO_MINOR * 1000
          + LIBMOSQUITTO_REVISION;
      return Version(major: LIBMOSQUITTO_MAJOR,
                     minor: LIBMOSQUITTO_MINOR,
                     revision: LIBMOSQUITTO_REVISION,
                     uniqueVersionNumber: LIBMOSQUITTO_VERSION_NUMBER)
    }

    public var hashValue: Int {
      return Int(uniqueVersionNumber)
    }

    public static func == (lhs: Version, rhs: Version) -> Bool {
      return lhs.uniqueVersionNumber == rhs.uniqueVersionNumber
    }
  }
}
