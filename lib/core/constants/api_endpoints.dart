import '../config/env.dart';

/// Routes of the LiveQR backend (liveqr-backend), relative to [baseUrl] (…/v1).
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => Env.apiBaseUrl;

  // Account
  static const String me = '/me';

  // AI: description → page spec (takes several seconds)
  static const String generatePage = '/ai/generate';

  // Pages: freeze the draft as a new version and (first time) give it its public link
  static String publishPage(String id) => '/pages/$id/publish';

  // Images (multipart field "file")
  static const String uploads = '/uploads';
}
