import Foundation

public extension SMosquitto {
  public struct Payload {
    internal let data: Data

    public init() {
      data = Data()
    }

    public init(_ string: String) {
      data = Data(string.utf8)
    }

    public init(rawPayload: UnsafeMutableRawPointer?, count: Int) {
      guard let rawPayload = rawPayload else { data = Data(); return }
      let pointer = rawPayload.bindMemory(to: UInt8.self, capacity: count)
      let bufferPointer = UnsafeBufferPointer(start: pointer, count: count)
      self.data = Data(bufferPointer)
    }

    public var count: Int32 {
      return Int32(data.count)
    }
  }
}

extension SMosquitto.Payload {
  public var string: String? {
    return String(bytes: data, encoding: .utf8)
  }
}
