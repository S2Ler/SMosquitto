import cmosquitto

public class SMosquitto {
  public static func initialize() {
    mosquitto_lib_init();
  }

  public static func cleanup() {
    mosquitto_lib_cleanup();
  }

  public static func version() -> SMosquittoVersion {
    return SMosquittoVersion()
  }
}
