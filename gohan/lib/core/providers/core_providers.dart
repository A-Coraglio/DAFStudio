import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../http/api_client.dart';
import '../storage/auth_storage.dart';

/// Auth lifecycle of the app.
///
/// `loading` is the boot state while we read the token from secure storage —
/// the router shows a splash in this window to avoid flashing /login.
enum SessionStatus { loading, authenticated, unauthenticated }

class SessionState {
  final SessionStatus status;
  final String? token;
  const SessionState._(this.status, [this.token]);

  static const loading = SessionState._(SessionStatus.loading);
  static const unauthenticated = SessionState._(SessionStatus.unauthenticated);
  factory SessionState.authenticated(String token) =>
      SessionState._(SessionStatus.authenticated, token);

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isLoading => status == SessionStatus.loading;
  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState.loading) {
    _restore();
  }

  Future<void> _restore() async {
    // A secure-storage failure must fall back to the login screen, never
    // leave the app stuck on the splash (loading) state forever.
    String? token;
    try {
      token = await AuthStorage.readToken();
    } catch (_) {
      token = null;
    }
    state = (token != null && token.isNotEmpty)
        ? SessionState.authenticated(token)
        : SessionState.unauthenticated;
  }

  Future<void> setToken(String token) async {
    await AuthStorage.saveToken(token);
    state = SessionState.authenticated(token);
  }

  Future<void> clear() async {
    await AuthStorage.clearToken();
    state = SessionState.unauthenticated;
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier();
});

/// Shared Dio instance. The auth interceptor calls back into the session
/// notifier on 401, so a stale token immediately logs the user out.
final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    onUnauthorized: () => ref.read(sessionProvider.notifier).clear(),
  );
});
