public extension SMosquitto {
  enum QOS: Int32 {
    case almostOnce = 0
    case atleastOnce = 1
    case exatlyOnce = 2
  }
}
