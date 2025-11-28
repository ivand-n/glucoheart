import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:glucoheart_flutter/data/datasources/remote/chat_api.dart';
import 'package:glucoheart_flutter/data/datasources/remote/chat_socket_service.dart';
import 'package:glucoheart_flutter/domain/entities/chat_message.dart';
import 'package:glucoheart_flutter/domain/entities/chat_session.dart';
import 'auth_provider.dart';

class NurseSessionsState {
  final bool isLoading;
  final String? error;
  final List<ChatSession> sessions;

  const NurseSessionsState({
    this.isLoading = false,
    this.error,
    this.sessions = const [],
  });

  NurseSessionsState copyWith({
    bool? isLoading,
    String? error,
    List<ChatSession>? sessions,
  }) {
    return NurseSessionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessions: sessions ?? this.sessions,
    );
  }
}

final nurseSessionsProvider =
StateNotifierProvider<NurseSessionsNotifier, NurseSessionsState>(
      (ref) => NurseSessionsNotifier(ref),
);

class NurseSessionsNotifier extends StateNotifier<NurseSessionsState> {
  NurseSessionsNotifier(this.ref)
      : _api = ChatApi(),
        _socket = ChatSocketService(),
        super(const NurseSessionsState());

  final Ref ref;
  final ChatApi _api;
  final ChatSocketService _socket;
  final _secure = const FlutterSecureStorage();

  bool _connected = false;
  final Set<int> _joinedSessionIds = {};

  void _syncRoomsWithSessions() {
    if (!_socket.isConnected) return;
    final current = state.sessions.map((s) => s.id).toSet();
    // leave yang sudah tidak ada
    final toLeave = _joinedSessionIds.difference(current);
    for (final id in toLeave) {
      _socket.leave(id);
      _joinedSessionIds.remove(id);
    }
    // join yang baru
    final toJoin = current.difference(_joinedSessionIds);
    for (final id in toJoin) {
      _socket.join(id);
      _joinedSessionIds.add(id);
    }
  }

  Future<void> loadAssignedSessions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final auth = ref.read(authProvider);
      final myId = int.tryParse(auth.user?.id ?? '') ?? -1;

      final raw = await _api.listSessions();
      final sessions = raw
          .cast<Map<String, dynamic>>()
          .map((e) => ChatSession.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.assignedNurseId == myId)
          .toList();

      sessions.sort((a, b) {
        final at = a.lastMessageAt ?? a.updatedAt;
        final bt = b.lastMessageAt ?? b.updatedAt;
        return bt.compareTo(at);
      });

      state = state.copyWith(isLoading: false, sessions: sessions);

      await _ensureSocketConnected();
      // _joinRoomsForCurrentSessions();
      _syncRoomsWithSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadAssignedSessions();

  Future<void> _ensureSocketConnected() async {
    if (_connected && _socket.isConnected) return;

    await _socket.connect(
      onMessage: _onNewMessage,
      onConnected: () {
        _syncRoomsWithSessions();
      },
      onDisconnected: () => _connected = false
    );
    _connected = _socket.isConnected;
  }

  void _onNewMessage(Map<String, dynamic> payload) {
    try {
      final msg = ChatMessage.fromJson(payload);

      // Pastikan message dari sesi yang memang diassign ke nurse ini
      final idx = state.sessions.indexWhere((s) => s.id == msg.sessionId);
      if (idx < 0) return;

      final List<ChatSession> updated = List.of(state.sessions);
      final s = updated[idx];

      final patched = ChatSession(
        id: s.id,
        type: s.type,
        userAId: s.userAId,
        userBId: s.userBId,
        assignedNurseId: s.assignedNurseId,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        lastMessageAt: msg.createdAt,
        lastMessage: msg,
      );

      updated[idx] = patched;
      updated.sort((a, b) {
        final at = a.lastMessageAt ?? a.updatedAt;
        final bt = b.lastMessageAt ?? b.updatedAt;
        return bt.compareTo(at);
      });

      state = state.copyWith(sessions: updated);
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _joinedSessionIds.clear();
      _socket.disconnect();
    } catch (_) {}
    super.dispose();
  }
}
