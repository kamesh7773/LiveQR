// The live iframe preview only exists in the browser; other platforms get a stub.
export 'web_page_frame/stub.dart'
    if (dart.library.js_interop) 'web_page_frame/web.dart';
