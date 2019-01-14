import Foundation
import cmosquitto

internal extension SMosquitto {
  internal struct Instances {
    private static let queue: DispatchQueue = DispatchQueue(label: "smosquitto.instances",
                                                            qos: .default,
                                                            attributes: .concurrent)
    private static var instances: [OpaquePointer: SMosquitto] = [:]

    /**
     Returns SMosquitto instance with specific handle.
     - note: Even though OpaquePointer? is expected, it is unexpected situation.
             This API exists just to simplify calling code.
     */
    public static func get(_ handle: OpaquePointer?) -> SMosquitto? {
      guard let handle = handle else {
        assertionFailure("Unexpected nil handle.")
        return nil
      }
      return queue.sync { instances[handle] }
    }

    public static func unwrapGet(_ handle: OpaquePointer?) -> SMosquitto? {
      guard let smosquitto = get(handle) else {
        assertionFailure("Unexpected nil handle")
        return nil
      }
      return smosquitto
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
