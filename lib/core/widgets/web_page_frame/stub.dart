import 'package:flutter/widgets.dart';

// ponytail: generated pages only preview in the web app; add a WebView here when mobile ships.
class WebPageFrame extends StatelessWidget {
  const WebPageFrame({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Open the web app to preview this page.'));
}
