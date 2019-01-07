import cmosquitto
import Foundation

public typealias MosqErrRawValue = Int32

public enum SMosquittoError: MosqErrRawValue {
  case connectionPending
  case noMemory
  case `protocol`
  case inval
  case noConnection
  case connectionRefused
  case notFound
  case connectionLost
  case tls
  case payloadSize
  case notSupported
  case auth
  case aclDenied
  case unknown
  case errno
  case eai
  case proxy
  case pluginDefer
  case malformedUtf8
  case keepalive
  case lookup

  internal init?(_ rawValue: MosqErrRawValue) {
    switch mosq_err_t(rawValue) {
    case MOSQ_ERR_CONN_PENDING:
      self = .connectionPending
    case MOSQ_ERR_NOMEM:
      self = .noMemory
    case MOSQ_ERR_PROTOCOL:
      self = .protocol
    case MOSQ_ERR_INVAL:
      self = .inval
    case MOSQ_ERR_NO_CONN:
      self = .noConnection
    case MOSQ_ERR_CONN_REFUSED:
      self = .connectionRefused
    case MOSQ_ERR_NOT_FOUND:
      self = .notFound
    case MOSQ_ERR_CONN_LOST:
      self = .connectionLost
    case MOSQ_ERR_TLS:
      self = .tls
    case MOSQ_ERR_PAYLOAD_SIZE:
      self = .payloadSize
    case MOSQ_ERR_NOT_SUPPORTED:
      self = .notSupported
    case MOSQ_ERR_AUTH:
      self = .auth
    case MOSQ_ERR_ACL_DENIED:
      self = .aclDenied
    case MOSQ_ERR_UNKNOWN:
      self = .unknown
    case MOSQ_ERR_ERRNO:
      self = .errno
    case MOSQ_ERR_EAI:
      self = .eai
    case MOSQ_ERR_PROXY:
      self = .proxy
    case MOSQ_ERR_PLUGIN_DEFER:
      self = .pluginDefer
    case MOSQ_ERR_MALFORMED_UTF8:
      self = .malformedUtf8
    case MOSQ_ERR_KEEPALIVE:
      self = .keepalive
    case MOSQ_ERR_LOOKUP:
      self = .lookup
    default:
      return nil
    }
  }
}

extension SMosquittoError: CustomStringConvertible {
  public var description: String {
    return String(cString: mosquitto_strerror(self.rawValue))
  }
}
