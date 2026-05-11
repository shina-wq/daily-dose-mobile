import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenManager {
  TokenManager._();

  static final TokenManager instance = TokenManager._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kIdToken = 'firebase_id_token';
  static const _kRefreshToken = 'firebase_refresh_token';

  /// Get current Firebase ID token
  Future<String?> getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      // Get fresh ID token from Firebase
      final token = await user.getIdToken(true);
      if (token != null) {
        await _storage.write(key: _kIdToken, value: token);
      }
      return token;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Restore token from secure storage
  Future<String?> getStoredIdToken() async {
    return await _storage.read(key: _kIdToken);
  }

  /// Check if current token is expired
  Future<bool> isTokenExpired() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return true;
      
      // Try to get a fresh token - if it fails, token is expired
      await user.getIdToken(true);
      return false;
    } catch (e) {
      return true;
    }
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: _kIdToken);
    await _storage.delete(key: _kRefreshToken);
  }

  /// Refresh token and return new token
  Future<String?> refreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final token = await user.getIdToken(true);
      if (token != null) {
        await _storage.write(key: _kIdToken, value: token);
      }
      return token;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
}
