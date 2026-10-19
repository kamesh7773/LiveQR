// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pages_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pagesRepository)
final pagesRepositoryProvider = PagesRepositoryProvider._();

final class PagesRepositoryProvider
    extends
        $FunctionalProvider<PagesRepository, PagesRepository, PagesRepository>
    with $Provider<PagesRepository> {
  PagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pagesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PagesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PagesRepository create(Ref ref) {
    return pagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PagesRepository>(value),
    );
  }
}

String _$pagesRepositoryHash() => r'7634eed644b37d2cf48d79b16a0d582c834bad0a';
