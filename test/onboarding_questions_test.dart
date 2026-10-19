import 'package:base_flutter_application/features/onboarding/models/onboarding_questions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final business = purposes.firstWhere((p) => p.label == 'Business page');

  test(
    'the prompt has only answered, visible questions, with Other spelled out',
    () {
      final a = Answers()
        ..picks['business.type'] = ['Other']
        ..texts['business.type.other'] = 'Tailoring'
        ..texts['business.name'] = ' Stitch & Co '
        ..picks['business.contact'] = ['WhatsApp']
        ..texts['business.contact.whatsapp'] = '+91 90000 12345'
        // Typed earlier, then "Phone call" was unpicked: the phone box is hidden, so it's left out.
        ..texts['business.contact.phone'] = '+91 11111 11111'
        ..texts['extras.notes'] = 'Line one\nLine two';

      expect(
        describe(business, a),
        'Page type: Business page\n'
        'Type of business: Tailoring\n'
        'Business name: Stitch & Co\n'
        'Contact by: WhatsApp\n'
        'WhatsApp number: +91 90000 12345\n'
        'Anything else:\nLine one\nLine two',
      );
    },
  );

  test('phone, email and link answers are checked', () {
    expect(invalidReason(InputKind.phone, '12'), isNotNull);
    expect(invalidReason(InputKind.phone, '+91 98765 43210'), isNull);
    expect(invalidReason(InputKind.email, 'me@'), isNotNull);
    expect(invalidReason(InputKind.email, 'me@shop.in'), isNull);
    expect(invalidReason(InputKind.url, 'not a link'), isNotNull);
    expect(invalidReason(InputKind.url, 'instagram.com/shop'), isNull);
    expect(
      invalidReason(InputKind.url, ''),
      isNull,
    ); // empty is for "required" to decide
  });

  test('every purpose asks at least one required question', () {
    for (final p in purposes) {
      expect(
        p.steps.expand((s) => s.questions).any((q) => q.required),
        isTrue,
        reason: p.label,
      );
    }
  });

  test('a main action asks for its missing detail, and only then', () {
    final whatsapp = business.steps
        .expand((s) => s.questions)
        .firstWhere((q) => q.id == 'business.action.whatsapp');
    final a = Answers()..picks['business.action'] = ['Message on WhatsApp'];
    expect(whatsapp.visible(a), isTrue); // no WhatsApp number given earlier
    expect(whatsapp.required, isTrue);

    a.picks['business.contact'] = ['WhatsApp'];
    expect(whatsapp.visible(a), isFalse); // already asked on the contact step
  });
}
