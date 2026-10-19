import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/base_api_service.dart';
import '../models/generated_page.dart';
import '../view_models/page_draft_view_model.dart';

part 'pages_repository.g.dart';

@riverpod
PagesRepository pagesRepository(Ref ref) => PagesRepository(ref);

class PagesRepository extends BaseApiService {
  PagesRepository(super.ref);

  /// Asks the backend's AI to write the page. Opus takes about 1–3 minutes.
  Future<GeneratedPage> generate(PageRequest request) async {
    final response = await post(
      ApiEndpoints.generatePage,
      data: {
        'description': request.description,
        'photos': request.photoIds,
        'links': request.links,
        if (request.pageId != null) 'pageId': request.pageId,
      },
      options: Options(receiveTimeout: const Duration(minutes: 10)),
    );
    return GeneratedPage.fromJson(response.data as Map<String, dynamic>);
  }

  /// Publishes the page's current draft and returns its permanent public link.
  Future<String> publish(String pageId) async {
    final response = await post(ApiEndpoints.publishPage(pageId));
    return response.data['publicUrl'] as String;
  }

  /// Uploads one photo (JPEG, PNG or WebP, max 5 MB) and returns its asset id.
  Future<String> uploadPhoto(Uint8List bytes, String fileName) async {
    final response = await post(
      ApiEndpoints.uploads,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      }),
    );
    return response.data['id'] as String;
  }
}
