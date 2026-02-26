class Logger {

  static void log(String topic, String message, {int level = 0}) {
    print("${topic}: $message");
  }

}
