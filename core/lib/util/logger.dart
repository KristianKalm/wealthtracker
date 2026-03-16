import 'dart:collection';

enum LogLevel { debug, info, warn, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String topic;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.topic,
    required this.message,
  });

  String get levelLabel {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warn:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  String toString() => '[$formattedTime] [$levelLabel] $topic: $message';
}

class Logger {
  static const int _maxEntries = 1000;
  static final Queue<LogEntry> _entries = Queue<LogEntry>();
  static final List<void Function()> _listeners = [];

  static List<LogEntry> get entries => List.unmodifiable(_entries);

  static void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  static void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  static void _add(LogLevel level, String topic, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      topic: topic,
      message: message,
    );
    _entries.addLast(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeFirst();
    }
    print(entry.toString());
    _notify();
  }

  static void debug(String topic, String message) => _add(LogLevel.debug, topic, message);
  static void info(String topic, String message) => _add(LogLevel.info, topic, message);
  static void warn(String topic, String message) => _add(LogLevel.warn, topic, message);
  static void error(String topic, String message) => _add(LogLevel.error, topic, message);

  /// Legacy compatibility
  static void log(String topic, String message, {int level = 0}) {
    final lvl = level == 0 ? LogLevel.info : (level < 0 ? LogLevel.debug : LogLevel.error);
    _add(lvl, topic, message);
  }

  static void clear() {
    _entries.clear();
    _notify();
  }

  static String exportAll() {
    return _entries.map((e) => e.toString()).join('\n');
  }
}
