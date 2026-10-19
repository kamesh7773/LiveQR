import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';

part 'home_view_model.g.dart';

/// GET /v1/me — the backend creates the user record on the first call.
@riverpod
Future<Map<String, dynamic>> backendProfile(Ref ref) async {
  final response = await ref.watch(apiClientProvider).get(ApiEndpoints.me);
  return response.data as Map<String, dynamic>;
}
