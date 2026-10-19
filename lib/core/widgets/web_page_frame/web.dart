import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Shows the page at [url] in an iframe. The backend also serves it with a CSP sandbox; the
/// iframe sandbox repeats that, so its scripts can never reach the app's origin or sign-in.
class WebPageFrame extends StatelessWidget {
  const WebPageFrame({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: ValueKey(url),
      tagName: 'iframe',
      onElementCreated: (element) {
        final frame = element as web.HTMLIFrameElement;
        frame
          ..src = url
          ..title = 'Page preview'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        frame.setAttribute(
          'sandbox',
          'allow-scripts allow-popups allow-popups-to-escape-sandbox allow-downloads allow-modals',
        );
      },
    );
  }
}
