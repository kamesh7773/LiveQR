/// A page the AI wrote, as returned by POST /v1/ai/generate.
/// The page itself is HTML stored by the backend and shown from [previewUrl].
class GeneratedPage {
  const GeneratedPage({
    required this.id,
    required this.title,
    required this.previewUrl,
    this.publicUrl,
  });

  final String id;
  final String title;
  final String previewUrl;

  /// The page's permanent public link (what its QR code opens), once it has been published.
  final String? publicUrl;

  factory GeneratedPage.fromJson(Map<String, dynamic> json) => GeneratedPage(
    id: json['id'] as String,
    title: json['title'] as String,
    previewUrl: json['previewUrl'] as String,
    publicUrl: json['publicUrl'] as String?,
  );
}
