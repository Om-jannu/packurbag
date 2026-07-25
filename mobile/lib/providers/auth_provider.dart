import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/token_storage.dart';
import '../models/user.dart';
import 'repository_providers.dart';

const _sessionPrefsKey = 'session_user';

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

/// Holds the signed-in [User] (or null when logged out), persisted to
/// SharedPreferences so the splash screen can restore a session on launch.
/// The actual credentials backing that session (access/refresh tokens) live
/// separately in [TokenStorage] — a cached profile with no refresh token is
/// treated as logged out, since there's no way to authenticate requests.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionPrefsKey);
    if (raw == null) return null;

    final refreshToken = await TokenStorage.instance.refreshToken;
    if (refreshToken == null) {
      await prefs.remove(_sessionPrefsKey);
      return null;
    }
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> login({
    required String userEmail,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .login(userEmail: userEmail, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionPrefsKey, jsonEncode(user.toJson()));
      return user;
    });
  }

  /// Registers a new account. Does not sign the user in — matches the
  /// original flow where registering returns you to the login screen.
  Future<void> register({
    required String username,
    required String userEmail,
    required String password,
  }) {
    return ref.read(authRepositoryProvider).register(
          username: username,
          userEmail: userEmail,
          password: password,
        );
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.instance.refreshToken;
    await ref.read(authRepositoryProvider).logout(refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefsKey);
    state = const AsyncData(null);
  }

  /// Called when a background request discovers the refresh token itself is
  /// dead (expired, revoked, or reused) — clears local session state
  /// without another round-trip, since there's nothing valid left to revoke.
  Future<void> clearSessionLocally() async {
    await TokenStorage.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefsKey);
    state = const AsyncData(null);
  }

  /// Mirrors the discoverability flag locally after toggling it via
  /// [DiscoveryRepository], so the rest of the UI stays in sync without
  /// re-fetching the whole session.
  Future<void> setDiscoverableLocally(bool isDiscoverable) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(isDiscoverable: isDiscoverable);
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionPrefsKey, jsonEncode(updated.toJson()));
  }
}
