import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
	ApiService();

	ApiService._();

	static final ApiService instance = ApiService._();

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
}