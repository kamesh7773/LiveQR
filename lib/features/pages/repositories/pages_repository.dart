import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/base_api_service.dart';
import '../models/page_spec.dart';
import '../view_models/page_draft_view_model.dart';

part 'pages_repository.g.dart';

@riverpod
PagesRepository pagesRepository(Ref ref) => PagesRepository(ref);

class PagesRepository extends BaseApiService {
  PagesRepository(super.ref);

  /// Asks the backend's AI for a page. Usually 5–30 seconds, so it gets a longer timeout.
  Future<PageSpec> generate(PageRequest request) async {
    final response = await post(
      ApiEndpoints.generatePage,
      data: {
        'description': request.description,
        'photos': request.photoIds,
        'links': request.links,
      },
      options: Options(receiveTimeout: const Duration(minutes: 2)),
    );
    return PageSpec.fromJson(response.data as Map<String, dynamic>);
  }

  /// Uploads one photo (JPEG, PNG or WebP, max 5 MB) and returns its asset id.
  Future<String> uploadPhoto(XFile file) async {
    final response = await post(
      ApiEndpoints.uploads,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        ),
      }),
    );
    return response.data['id'] as String;
  }
}
