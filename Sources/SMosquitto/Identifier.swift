import Foundation

public extension SMosquitto {
  struct Identifier<Value>: RawRepresentable, Hashable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }
  }
}

extension SMosquitto.Identifier: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int32) {
    rawValue = value
  }
}
