import Foundation
import cmosquitto

internal extension SMosquitto {
  internal struct Instances {
    private static let queue: DispatchQueue = DispatchQueue(label: "smosquitto.instances",
                                                            qos: .default,
                                                            attributes: .concurrent)
    private static var instances: [OpaquePointer: SMosquitto] = [:]

    public static func get(_ handle: OpaquePointer) -> SMosquitto? {
      return queue.sync { instances[handle] }
    }

    public static func set(_ handle: OpaquePointer, _ smosquitto: SMosquitto) {
      queue.async(flags: .barrier) {
        instances[handle] = smosquitto
      }
    }

    public static func clear(_ handle: OpaquePointer) {
      queue.async(flags: .barrier) {
        instances[handle] = nil
      }
    }
  }
}
