import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/dialog_service.dart';
import '../repositories/auth_repository.dart';

part 'auth_view_model.g.dart';

/// Signed-in Firebase user, or null (a guest).
@Riverpod(keepAlive: true)
Stream<User?> authUser(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

/// Sign-in actions. State is `true` while a request is in flight.
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  bool build() => false;

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  DialogService get _dialog => ref.read(dialogServiceProvider.notifier);

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _repo.signInWithEmail(email, password));

  Future<void> signUpWithEmail(String email, String password) =>
      _run(() => _repo.signUpWithEmail(email, password));

  Future<void> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<void> signInWithApple() => _run(_repo.signInWithApple);

  Future<void> sendPasswordReset(String email) async {
    if (await _run(() => _repo.sendPasswordReset(email))) {
      _dialog.showSuccess('Password reset email sent to $email');
    }
  }

  Future<void> signOut() => _run(_repo.signOut);

  /// Runs [action], toasting failures. User cancellations are silent.
  Future<bool> _run(Future<void> Function() action) async {
    state = true;
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      if (!e.code.contains('cancel')) {
        _dialog.showError(e.message ?? 'Sign-in failed');
      }
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _dialog.showError(e.description ?? 'Google sign-in failed');
      }
    } finally {
      // The login screen (and this notifier) is disposed once sign-in succeeds.
      if (ref.mounted) state = false;
    }
    return false;
  }
}
