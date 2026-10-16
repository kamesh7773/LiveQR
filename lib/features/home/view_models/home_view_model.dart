import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import '../models/live_page.dart';

part 'home_view_model.g.dart';

/// GET /v1/me — the backend creates the user record on the first call.
@riverpod
Future<Map<String, dynamic>> backendProfile(Ref ref) async {
  final response = await ref.watch(apiClientProvider).get(ApiEndpoints.me);
  return response.data as Map<String, dynamic>;
}

/// The signed-in owner's pages. An empty list shows the first-visit layout.
// ponytail: sample data until the backend has GET /v1/pages; return const [] to preview the first visit.
@riverpod
List<LivePage> myPages(Ref ref) => const [
  LivePage(
    id: 'daily-brew',
    title: 'The Daily Brew',
    type: PageType.menu,
    isLive: true,
    scansThisWeek: 248,
  ),
  LivePage(
    id: 'asha-rao',
    title: 'Asha Rao',
    type: PageType.card,
    isLive: false,
  ),
];
