class UrlUtils {
  static const String base = String.fromEnvironment('BASE_URL', defaultValue: 'http://195.88.211.126:3001');

  static String full(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }
}
