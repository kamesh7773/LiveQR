// Firebase config for project `liveqr-maxaix`, one app per flavor.
// Values come from `firebase apps:sdkconfig`; they identify the app and are
// not secrets. Regenerate them there if an app is re-registered.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'core/config/env.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// Web OAuth client; google_sign_in needs it to issue ID tokens Firebase accepts.
  static const String googleServerClientId =
      '714496427127-qm8d7h9ooq3s1s83cspgfb929v9kjofd.apps.googleusercontent.com';

  static const _androidApiKey = 'AIzaSyCpYPqcFWfvqSxrtpcnVI0rMJ5OiiSWafk';
  static const _iosApiKey = 'AIzaSyBIfElPiOLUqLcvNHa9ZN5L2Z8soxqD_Ls';
  static const _senderId = '714496427127';
  static const _projectId = 'liveqr-maxaix';
  static const _storageBucket = 'liveqr-maxaix.firebasestorage.app';

  // One web app serves every flavor; only sign-in uses it.
  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDlAPSiEx0PVSwHbCKPV8OVJt4Jt_CSVvc',
    appId: '1:714496427127:web:6d9c899ece5941eb523272',
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: 'liveqr-maxaix.firebaseapp.com',
    storageBucket: _storageBucket,
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    final env = Env.environment;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _android(switch (env) {
        Environment.development =>
          '1:714496427127:android:64c7b44e5adedb9e523272',
        Environment.staging => '1:714496427127:android:438ad55fbc37a3d3523272',
        Environment.production =>
          '1:714496427127:android:8eeb4db7b1373c66523272',
      }),
      TargetPlatform.iOS => switch (env) {
        Environment.development => _ios(
          '1:714496427127:ios:4c693cf640dac411523272',
          '714496427127-us3ah9ibadvlba5ur6iq2o2dr8kgr3vp.apps.googleusercontent.com',
          'com.maxaix.liveqr.dev',
        ),
        Environment.staging => _ios(
          '1:714496427127:ios:9c06abd62eb4e152523272',
          '714496427127-15q8oagmnngq7mplr70rfvajej66jris.apps.googleusercontent.com',
          'com.maxaix.liveqr.staging',
        ),
        Environment.production => _ios(
          '1:714496427127:ios:8d166e05f33d96a1523272',
          '714496427127-upnmh9eg0d5keunturlkpijaoe2lac22.apps.googleusercontent.com',
          'com.maxaix.liveqr',
        ),
      },
      _ => throw UnsupportedError(
        'Firebase is only configured for web, Android and iOS.',
      ),
    };
  }

  static FirebaseOptions _android(String appId) => FirebaseOptions(
    apiKey: _androidApiKey,
    appId: appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static FirebaseOptions _ios(String appId, String clientId, String bundleId) =>
      FirebaseOptions(
        apiKey: _iosApiKey,
        appId: appId,
        messagingSenderId: _senderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosClientId: clientId,
        iosBundleId: bundleId,
      );
}
