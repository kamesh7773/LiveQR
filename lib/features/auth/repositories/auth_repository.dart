import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../firebase_options.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(FirebaseAuth.instance);

/// Thin wrapper over Firebase Auth for email, Google and Apple sign-in.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _google = GoogleSignIn.instance;
  Future<void>? _googleInit;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signInWithGoogle() async {
    // google_sign_in has no authenticate() on web; Firebase's popup does the job.
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    // google_sign_in v7 must be initialized exactly once before use.
    await (_googleInit ??= _google.initialize(
      clientId: Firebase.app().options.iosClientId,
      serverClientId: DefaultFirebaseOptions.googleServerClientId,
    ));
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  /// Popup on web, native sheet on iOS, Firebase's web flow on Android.
  Future<void> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);
  }

  Future<void> signOut() async {
    if (_googleInit != null) await _google.signOut();
    await _auth.signOut();
  }
}
