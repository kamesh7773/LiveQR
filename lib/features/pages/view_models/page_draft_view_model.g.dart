// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_draft_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The page generated from [request]. Invalidate it to generate again.

@ProviderFor(pageDraft)
final pageDraftProvider = PageDraftFamily._();

/// The page generated from [request]. Invalidate it to generate again.

final class PageDraftProvider
    extends
        $FunctionalProvider<
          AsyncValue<GeneratedPage>,
          GeneratedPage,
          FutureOr<GeneratedPage>
        >
    with $FutureModifier<GeneratedPage>, $FutureProvider<GeneratedPage> {
  /// The page generated from [request]. Invalidate it to generate again.
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
  $FutureProviderElement<GeneratedPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GeneratedPage> create(Ref ref) {
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

String _$pageDraftHash() => r'a2fbd4d7f1276b71e72216855c7f695bce1d3019';

/// The page generated from [request]. Invalidate it to generate again.

final class PageDraftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GeneratedPage>, PageRequest> {
  PageDraftFamily._()
    : super(
        retry: null,
        name: r'pageDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The page generated from [request]. Invalidate it to generate again.

  PageDraftProvider call(PageRequest request) =>
      PageDraftProvider._(argument: request, from: this);

  @override
  String toString() => r'pageDraftProvider';
}
