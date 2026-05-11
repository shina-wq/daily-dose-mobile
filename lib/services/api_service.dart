import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/token_manager.dart';
import '../core/navigation/app_router.dart';

typedef OnTokenExpired = void Function();

class ApiService {
	ApiService();

	ApiService._();

	// Made non-final so tests can inject a mock instance.
	static ApiService instance = ApiService._();
	
	// Callback when token expires
	static OnTokenExpired? onTokenExpired;

	/// Replace the active singleton with a test instance.
	static void setInstanceForTesting(ApiService service) {
		instance = service;
	}

	static const String _defaultWebBaseUrl = 'http://localhost:8080';
	static const String _defaultAndroidBaseUrl = 'http://10.0.2.2:8080';
	static const String _defaultMobileDesktopBaseUrl = 'http://localhost:8080';

	String get _baseUrl {
		const configured = String.fromEnvironment('DAILY_DOSE_API_BASE_URL');
		if (configured.isNotEmpty) {
			return configured;
		}

		if (kIsWeb) {
			return _defaultWebBaseUrl;
		}

		switch (defaultTargetPlatform) {
			case TargetPlatform.android:
				return _defaultAndroidBaseUrl;
			default:
				return _defaultMobileDesktopBaseUrl;
		}
	}

	Future<Map<String, dynamic>> fetchHomeDashboard(String uid) async {
		final uri = Uri.parse('$_baseUrl/api/home/$uid');

		final response = await http
				.get(uri, headers: const {'Content-Type': 'application/json'})
				.timeout(const Duration(seconds: 15));

		_handleAuthError(response.statusCode);

		final decoded = jsonDecode(response.body);
		if (response.statusCode >= 400) {
			final message = decoded is Map<String, dynamic>
					? (decoded['error'] as String?) ?? 'Request failed.'
					: 'Request failed.';
			throw Exception(message);
		}

		if (decoded is! Map<String, dynamic>) {
			throw Exception('Unexpected API response format.');
		}

		return decoded;
	}

	Future<Map<String, dynamic>?> fetchCurrentUserProfile(String uid) async {
		final uri = Uri.parse('$_baseUrl/api/profile/$uid');

		final response = await http
				.get(uri, headers: const {'Content-Type': 'application/json'})
				.timeout(const Duration(seconds: 15));

		_handleAuthError(response.statusCode);

		final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
		if (response.statusCode == 404) {
			return null;
		}

		if (response.statusCode >= 400) {
			final message = decoded is Map<String, dynamic>
					? (decoded['error'] as String?) ?? 'Request failed.'
					: 'Request failed.';
			throw Exception(message);
		}

		if (decoded is! Map<String, dynamic>) {
			throw Exception('Unexpected API response format.');
		}

		return decoded;
	}

	/// Handle authentication errors (401, 403)
	void _handleAuthError(int statusCode) {
		if (statusCode == 401 || statusCode == 403) {
			// Token expired or unauthorized
			_logout();
			onTokenExpired?.call();
			throw Exception('Session expired. Please log in again.');
		}
	}

	/// Logout user when token is invalid
	void _logout() {
		FirebaseAuth.instance.signOut();
		TokenManager.instance.clearTokens();
	}
}