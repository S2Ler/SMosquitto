import cmosquitto
import Foundation

public typealias MosqErrRawValue = Int32
private let SuccessReturnCode = MOSQ_ERR_SUCCESS.rawValue;

public enum SMosquittoError: MosqErrRawValue, Swift.Error {
  case connectionPending = -1
  case noMemory = 1
  case `protocol` = 2
  case inval = 3
  case noConnection = 4
  case connectionRefused = 5
  case notFound = 6
  case connectionLost = 7
  case tls = 8
  case payloadSize = 9
  case notSupported = 10
  case auth = 11
  case aclDenied = 12
  case unknown = 13
  case errno = 14
  case eai = 15
  case proxy = 16
  case pluginDefer = 17
  case malformedUtf8 = 18
  case keepalive = 19
  case lookup = 20
}

extension SMosquittoError: CustomStringConvertible {
  public var description: String {
    return String(cString: mosquitto_strerror(self.rawValue))
  }
}

internal extension MosqErrRawValue {
  func failable() throws {
    guard self != SuccessReturnCode else {
      return
    }

    if let error = SMosquittoError(rawValue: self) {
      throw error
    }
    else {
      throw SMosquittoError.unknown
    }
  }

  func toSMosquittoError() -> SMosquittoError {
    if let error = SMosquittoError(rawValue: self as MosqErrRawValue) {
      return error
    }
    else {
      return .unknown
    }
  }
}
