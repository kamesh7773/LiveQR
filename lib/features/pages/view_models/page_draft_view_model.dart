import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/generated_page.dart';
import '../repositories/pages_repository.dart';

part 'page_draft_view_model.g.dart';

/// What the owner sent to generate a page.
/// No `==` override: the draft screen keeps one instance, which is the provider key.
class PageRequest {
  const PageRequest(
    this.description, {
    this.photoIds = const [],
    this.links = const [],
    this.pageId,
  });

  final String description;

  /// Asset ids returned by POST /v1/uploads.
  final List<String> photoIds;
  final List<String> links;

  /// Regenerate into this existing page instead of creating a new one.
  final String? pageId;

  /// The same request again (optionally with a new [description]), written into page [id].
  PageRequest retryInto(String id, {String? description}) => PageRequest(
    description ?? this.description,
    photoIds: photoIds,
    links: links,
    pageId: id,
  );
}

/// The page generated from [request]. Invalidate it to generate again.
@riverpod
Future<GeneratedPage> pageDraft(Ref ref, PageRequest request) =>
    ref.watch(pagesRepositoryProvider).generate(request);
