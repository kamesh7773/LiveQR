import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Opens [url] in a new browser tab, cut off from this one.
void openInNewTab(String url) => web.window.open(url, '_blank', 'noopener');

/// Saves [bytes] as a download named [fileName].
void downloadBytes(Uint8List bytes, String fileName, String mimeType) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  (web.HTMLAnchorElement()
        ..href = url
        ..download = fileName)
      .click();
  // Give the browser a moment to start the download before freeing the blob.
  Timer(const Duration(seconds: 5), () => web.URL.revokeObjectURL(url));
}
