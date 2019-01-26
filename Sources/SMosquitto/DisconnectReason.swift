import Foundation

public extension SMosquitto {
  enum DisconnectReason {
    case userInitiated
    case error(SMosquittoError)

    internal init(_ rawDisconnectReason: Int32) {
      switch rawDisconnectReason {
      case 0:
        self = .userInitiated
      default:
        self = .error(rawDisconnectReason.toSMosquittoError())
      }
    }
  }
}
