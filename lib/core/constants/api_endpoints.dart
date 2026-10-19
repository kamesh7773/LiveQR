import '../config/env.dart';

/// Routes of the LiveQR backend (liveqr-backend), relative to [baseUrl] (…/v1).
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => Env.apiBaseUrl;

  // Account
  static const String me = '/me';

  // AI: description → page spec (takes several seconds)
  static const String generatePage = '/ai/generate';

  // Images (multipart field "file")
  static const String uploads = '/uploads';
}
