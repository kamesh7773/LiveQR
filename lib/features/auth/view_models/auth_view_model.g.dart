// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signed-in Firebase user, or null. Drives [AuthGate].

@ProviderFor(authUser)
final authUserProvider = AuthUserProvider._();

/// Signed-in Firebase user, or null. Drives [AuthGate].

final class AuthUserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Signed-in Firebase user, or null. Drives [AuthGate].
  AuthUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authUser(ref);
  }
}

String _$authUserHash() => r'3a698a91d3905e6f68c36125b3c521d266d34f36';

/// Sign-in actions. State is `true` while a request is in flight.

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

/// Sign-in actions. State is `true` while a request is in flight.
final class AuthViewModelProvider
    extends $NotifierProvider<AuthViewModel, bool> {
  /// Sign-in actions. State is `true` while a request is in flight.
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authViewModelHash() => r'0b63cec1a37d6701bdba449628d0a4b44dab8161';

/// Sign-in actions. State is `true` while a request is in flight.

abstract class _$AuthViewModel extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
