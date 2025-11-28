import 'dart:developer' as developer;

class Logger {
  static const String _defaultTag = 'GLUCOHEART';
  static bool _enableLogs = true;

  static void enableLogs(bool enable) {
    _enableLogs = enable;
  }

  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, tag, error, stackTrace);
  }

  static void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, tag, error, stackTrace);
  }

  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('WARNING', message, tag, error, stackTrace);
  }

  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag, error, stackTrace);
  }

  static void _log(
      String level,
      String message,
      String? tag,
      Object? error,
      StackTrace? stackTrace,
      ) {
    if (!_enableLogs) return;

    final finalTag = tag ?? _defaultTag;
    final timestamp = DateTime.now().toString().substring(0, 19);
    final logMessage = '[$timestamp] $level [$finalTag]: $message';

    developer.log(
      logMessage,
      name: finalTag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logHttpRequest(String method, String url, {dynamic body, Map<String, dynamic>? headers}) {
    if (!_enableLogs) return;
    d('→ $method $url');
    if (headers != null) {
      d('→ Headers: $headers');
    }
    if (body != null) {
      d('→ Body: $body');
    }
  }

  static void logHttpResponse(int statusCode, String url, dynamic body) {
    if (!_enableLogs) return;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✓' : '✗';
    d('← $emoji HTTP $statusCode from $url');
    d('← Body: $body');
  }

  static void logWebSocket(String event, dynamic data) {
    if (!_enableLogs) return;
    d('⚡ $event: $data');
  }
}