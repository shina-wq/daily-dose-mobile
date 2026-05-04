import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../models/home_dashboard_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService.instance);

final homeDashboardProvider = FutureProvider.autoDispose<HomeDashboardModel>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;

  if (uid == null || uid.isEmpty) {
    throw Exception('Sign in to load your dashboard.');
  }

  final api = ref.watch(apiServiceProvider);
  final payload = await api.fetchHomeDashboard(uid);
  return HomeDashboardModel.fromJson(payload);
});