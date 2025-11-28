import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../utils/logger.dart';

typedef ChatMessageHandler = void Function(Map<String, dynamic> message);
typedef VoidHandler = void Function();

class ChatSocketService {
  IO.Socket? _socket;
  bool get isConnected => _socket?.connected == true;

  static const _base = String.fromEnvironment('BASE_URL', defaultValue: 'http://195.88.211.126:3001');
  final _storage = const FlutterSecureStorage();

  /// 🔹 CONNECT tanpa auto-join room. Pakai ini untuk use-case Nurse.
  Future<void> connect({
    required ChatMessageHandler onMessage,
    VoidHandler? onConnected,
    VoidHandler? onDisconnected,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      Logger.w('ChatSocket: no token', tag: 'ChatSocket');
      return;
    }

    // Jika sudah connect, tidak usah buat ulang
    if (_socket?.connected == true) {
      return;
    }

    _socket = IO.io('$_base/chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
        // Header Authorization + query token (jaga-jaga)
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setQuery({'token': token})
            .build());

    _socket!.onConnect((_) {
      Logger.d('ChatSocket connected', tag: 'ChatSocket');
      onConnected?.call();
    });

    // Saat reconnect, panggil onConnected juga biar provider bisa rejoin rooms
    _socket!.onReconnect((_) {
      Logger.d('ChatSocket reconnected', tag: 'ChatSocket');
      onConnected?.call();
    });

    _socket!.on('message.new', (data) {
      try {
        onMessage(Map<String, dynamic>.from(data as Map));
      } catch (e) {
        Logger.e('ChatSocket message.new invalid payload: $data', tag: 'ChatSocket', error: e);
      }
    });

    _socket!.onDisconnect((_) {
      Logger.w('ChatSocket disconnected', tag: 'ChatSocket');
      onDisconnected?.call();
    });

    _socket!.onError((e) => Logger.e('ChatSocket error: $e', tag: 'ChatSocket'));
  }

  /// ✅ Back-compat: connect + auto-join satu room (dipakai ChatScreen lama)
  Future<void> connectAndJoin({
    required int sessionId,
    required ChatMessageHandler onMessage,
  }) async {
    await connect(onMessage: onMessage, onConnected: () {
      join(sessionId);
    });
  }

  /// 🔹 Join room tertentu (boleh dipanggil berkali-kali)
  void join(int sessionId) {
    if (_socket?.connected == true) {
      _socket!.emit('session.join', {'sessionId': sessionId});
    }
  }

  /// 🔹 Leave room tertentu
  void leave(int sessionId) {
    if (_socket?.connected == true) {
      _socket!.emit('session.leave', {'sessionId': sessionId});
    }
  }

  void disconnect() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }
}
