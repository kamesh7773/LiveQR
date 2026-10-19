// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GET /v1/me — the backend creates the user record on the first call.

@ProviderFor(backendProfile)
final backendProfileProvider = BackendProfileProvider._();

/// GET /v1/me — the backend creates the user record on the first call.

final class BackendProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// GET /v1/me — the backend creates the user record on the first call.
  BackendProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendProfileHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return backendProfile(ref);
  }
}

String _$backendProfileHash() => r'd02ec803407506681b2d938823b86840c9fec9e2';
