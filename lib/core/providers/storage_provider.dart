import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/token_storage.dart';

final userStorageProvider = Provider<UserStorage>((ref) {
	return UserStorage.instance;
});