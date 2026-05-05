import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorage {
	UserStorage();

	UserStorage._();

	static final UserStorage instance = UserStorage._();

	final FlutterSecureStorage _storage = const FlutterSecureStorage();

	static const _kUid = 'user_uid';
	static const _kName = 'user_name';
	static const _kEmail = 'user_email';
	static const _kOnboarded = 'user_onboarded';

	Future<void> saveBasic({String? uid, required String email, String? name}) async {
		if (uid != null) await _storage.write(key: _kUid, value: uid);
		await _storage.write(key: _kEmail, value: email);
		if (name != null) await _storage.write(key: _kName, value: name);
	}

	Future<Map<String, String?>> readBasic() async {
		final uid = await _storage.read(key: _kUid);
		final email = await _storage.read(key: _kEmail);
		final name = await _storage.read(key: _kName);
		final onboarded = await _storage.read(key: _kOnboarded);
		return {'uid': uid, 'email': email, 'name': name, 'onboarded': onboarded};
	}

	Future<void> setOnboarded(bool value) async {
		await _storage.write(key: _kOnboarded, value: value ? '1' : '0');
	}

	Future<bool> isOnboarded() async {
		final v = await _storage.read(key: _kOnboarded);
		return v == '1';
	}

	Future<void> clear() async {
		await _storage.delete(key: _kUid);
		await _storage.delete(key: _kEmail);
		await _storage.delete(key: _kName);
		await _storage.delete(key: _kOnboarded);
	}
}