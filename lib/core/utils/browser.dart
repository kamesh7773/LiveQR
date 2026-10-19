// Browser-only actions; other platforms get no-op stubs until mobile ships.
export 'browser/stub.dart' if (dart.library.js_interop) 'browser/web.dart';
