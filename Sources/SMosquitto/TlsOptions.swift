import Foundation

public extension SMosquitto {
  /**
   The verification requirements the client will impose on the server.
   The default and recommended value is SSL_VERIFY_PEER. Using SSL_VERIFY_NONE provides no security.
   */
  enum CertificateRequirements: Int32 {
    /// The server will not be verified in any way.
    case sslVerifyNone = 0
    /// The server certificate will be verified and the connection aborted if the verification fails.
    case sslVerifyPeer = 1
  }

  enum TlsVersion {
    case tls_v_1
    case tls_v_1_1
    case tls_v_1_2
    case raw(String)

    internal var rawVersion: String {
      switch self {
      case .tls_v_1:
        return "tlsv1"
      case .tls_v_1_1:
        return "tlsv1.1"
      case .tls_v_1_2:
        return "tlv1.2"
      case .raw(let rawVersion):
        return rawVersion
      }
    }
  }

  struct Ciphers: ExpressibleByStringLiteral {
    internal let rawString: String

    public init(stringLiteral value: String) {
      self.rawString = value
    }
  }

  struct TlsOptions {
    public let certificateRequirements: CertificateRequirements
    public let tlsVersion: TlsVersion
    public let ciphers: Ciphers?

    public init(certificateRequirements: CertificateRequirements = .sslVerifyPeer,
                tlsVersion: TlsVersion = .tls_v_1_2,
                ciphers: Ciphers? = nil) {
      self.certificateRequirements = certificateRequirements
      self.tlsVersion = tlsVersion
      self.ciphers = ciphers
    }
  }
}
