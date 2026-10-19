// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_draft_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The page generated from [request]. Invalidate it to generate again.
// ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.

@ProviderFor(pageDraft)
final pageDraftProvider = PageDraftFamily._();

/// The page generated from [request]. Invalidate it to generate again.
// ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.

final class PageDraftProvider
    extends
        $FunctionalProvider<AsyncValue<PageSpec>, PageSpec, FutureOr<PageSpec>>
    with $FutureModifier<PageSpec>, $FutureProvider<PageSpec> {
  /// The page generated from [request]. Invalidate it to generate again.
  // ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.
  PageDraftProvider._({
    required PageDraftFamily super.from,
    required PageRequest super.argument,
  }) : super(
         retry: null,
         name: r'pageDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageDraftHash();

  @override
  String toString() {
    return r'pageDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PageSpec> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PageSpec> create(Ref ref) {
    final argument = this.argument as PageRequest;
    return pageDraft(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PageDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageDraftHash() => r'5db449bc7801bbee19bb005c20b7f5a2231810ec';

/// The page generated from [request]. Invalidate it to generate again.
// ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.

final class PageDraftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PageSpec>, PageRequest> {
  PageDraftFamily._()
    : super(
        retry: null,
        name: r'pageDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The page generated from [request]. Invalidate it to generate again.
  // ponytail: not saved anywhere yet — leaving the screen discards it until pages live in MongoDB.

  PageDraftProvider call(PageRequest request) =>
      PageDraftProvider._(argument: request, from: this);

  @override
  String toString() => r'pageDraftProvider';
}
