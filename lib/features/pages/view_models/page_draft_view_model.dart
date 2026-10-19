import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/page_spec.dart';
import '../repositories/pages_repository.dart';

part 'page_draft_view_model.g.dart';

/// What the owner sent to generate a page.
/// No `==` override: the draft screen keeps one instance, which is the provider key.
class PageRequest {
  const PageRequest(
    this.description, {
    this.photoIds = const [],
    this.links = const [],
  });

  final String description;

  /// Asset ids returned by POST /v1/uploads.
  final List<String> photoIds;
  final List<String> links;
}

/// The page generated from [request]. Invalidate it to generate again.
// ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.
@riverpod
Future<PageSpec> pageDraft(Ref ref, PageRequest request) =>
    ref.watch(pagesRepositoryProvider).generate(request);
