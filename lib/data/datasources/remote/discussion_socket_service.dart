import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../utils/logger.dart';

// Untuk room chat (detail pesan)
typedef MessageCreatedHandler = void Function(Map<String, dynamic> messageJson);

// Untuk list room (update preview/urutan)
typedef RoomUpdatedHandler = void Function(Map<String, dynamic> payloadJson);

class DiscussionSocketService {
  IO.Socket? _socket;
  bool get isConnected => _socket?.connected == true;

  IO.Socket _buildSocket(String url, String token) {
    return IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token})
          .build(),
    );
  }

  /// Koneksi untuk ROOM CHAT
  void connect({
    required String baseUrl,
    required String token,
    required int roomId,
    required MessageCreatedHandler onMessageCreated,
  }) {
    final url = '$baseUrl/discussion';
    _socket = _buildSocket(url, token);

    _socket!.on('discussion.message.new', (data) {
      try {
        if (data is Map) {
          onMessageCreated(Map<String, dynamic>.from(data)); // payload = 1 message (flat)
        } else {
          Logger.w('Unexpected payload type (room): $data', tag: 'Socket');
        }
      } catch (e) {
        Logger.e('Invalid payload on discussion.message.created: $data',
            tag: 'Socket', error: e);
      }
    });

    _socket!.onDisconnect((_) => Logger.w('Socket disconnected', tag: 'Socket'));
    _socket!.onError((e) => Logger.e('Socket error: $e', tag: 'Socket'));
    _socket!.onConnectError((e) => Logger.e('connect_error: $e', tag: 'Socket'));
  }

  /// Koneksi untuk LOBBY (list room)
  void connectLobby({
    required String baseUrl,
    required String token,
    required RoomUpdatedHandler onRoomUpdated,
  }) {
    final url = '$baseUrl/discussion';
    _socket = _buildSocket(url, token);

    // Bridge: anggap setiap message baru = update untuk room terkait.
    _socket!.on('discussion.message.new', (data) {
        try {
            if (data is Map) {
                final msg = Map<String, dynamic>.from(data);
                final roomId = (msg['roomId'] as num?)?.toInt();
                if (roomId != null) {
                  onRoomUpdated({
                    'roomId': roomId,
                    'lastMessage': msg, // bentuk yang diharapkan repository lama
                  });
                }
            } else {
              Logger.w('Unexpected payload type (lobby): $data', tag: 'Socket');
            }
        } catch (e) {
            Logger.e('Invalid payload on discussion.message.new (lobby bridge): $data',
                tag: 'Socket', error: e);
        }
      });

    _socket!.onDisconnect((_) => Logger.w('Socket disconnected', tag: 'Socket'));
    _socket!.onError((e) => Logger.e('Socket error: $e', tag: 'Socket'));
    _socket!.onConnectError((e) => Logger.e('connect_error: $e', tag: 'Socket'));
  }

  void leaveRoom(int roomId) {
    if (_socket?.connected == true) {
      _socket!.emit('discussion.leave', {'roomId': roomId});
    }
  }

  void disconnect() {
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }
}
