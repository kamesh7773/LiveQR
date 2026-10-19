// The guided "What would you like to create?" questions, from
// docs/liveqr_complete_onboarding_question_bank.md, trimmed to what a sandboxed page can do:
// no contact or RSVP forms (pages can't send data), booking/ordering only through the owner's link.

enum InputKind { text, multiline, phone, email, url }

/// One question on a step. [label] is shown above it and names the answer in the prompt.
sealed class Question {
  const Question(this.id, this.label, {this.required = false, this.showIf});

  final String id;
  final String label;
  final bool required;

  /// Shown only when this returns true (e.g. a phone box only if "Phone call" is picked).
  final bool Function(Answers answers)? showIf;

  bool visible(Answers answers) => showIf?.call(answers) ?? true;
}

class ChipQuestion extends Question {
  const ChipQuestion(
    super.id,
    super.label, {
    required this.options,
    this.multi = false,
    this.other = true,
    super.required,
    super.showIf,
  });

  final List<String> options;
  final bool multi;

  /// Adds an "Other" chip that reveals a text box.
  final bool other;
}

class TextQuestion extends Question {
  const TextQuestion(
    super.id,
    super.label, {
    this.hint = '',
    this.kind = InputKind.text,
    super.required,
    super.showIf,
  });

  final String hint;
  final InputKind kind;
}

class OnboardingStep {
  const OnboardingStep(this.title, this.questions, {this.subtitle});

  final String title;
  final String? subtitle;
  final List<Question> questions;
}

class Purpose {
  const Purpose(this.label, this.note, this.icon, this.steps);

  final String label;
  final String note;
  final String icon;
  final List<OnboardingStep> steps;
}

const otherChip = 'Other';

/// The owner's answers: chip picks (in order) and text, keyed by question id.
class Answers {
  final Map<String, List<String>> picks = {};
  final Map<String, String> texts = {};

  List<String> picked(String id) => picks[id] ?? const [];
  String text(String id) => texts[id]?.trim() ?? '';
  String otherText(String id) => text('$id.other');

  bool get isEmpty =>
      picks.values.every((p) => p.isEmpty) &&
      texts.values.every((t) => t.trim().isEmpty);
}

bool Function(Answers) _picked(String id, List<String> any) =>
    (a) => a.picked(id).any(any.contains);

/// Asks for the detail an action needs (e.g. a WhatsApp number for "Message on WhatsApp")
/// when [option] is picked in [actionId] but the owner hasn't given that detail earlier.
TextQuestion _needed(
  String id,
  String label,
  InputKind kind, {
  required String actionId,
  required String option,
  required bool Function(Answers) given,
}) => TextQuestion(
  id,
  label,
  hint: switch (kind) {
    InputKind.phone => '+91 98765 43210',
    InputKind.email => 'you@example.com',
    InputKind.url => 'yourbusiness.com',
    InputKind.text || InputKind.multiline => '',
  },
  kind: kind,
  required: true,
  showIf: (a) => a.picked(actionId).contains(option) && !given(a),
);

bool Function(Answers) _hasContact(String id, String option) =>
    (a) => a.picked(id).contains(option);

bool Function(Answers) _hasText(List<String> ids) =>
    (a) => ids.any((id) => a.text(id).isNotEmpty);

/// Why [value] isn't valid for [kind], or null if it's fine (empty is fine; required is separate).
String? invalidReason(InputKind kind, String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  switch (kind) {
    case InputKind.phone:
      final digits = v.replaceAll(RegExp(r'\D'), '').length;
      return digits < 7 || digits > 15
          ? 'Enter a phone number, e.g. +91 98765 43210'
          : null;
    case InputKind.email:
      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
          ? null
          : 'Enter an email, e.g. hello@shop.com';
    case InputKind.url:
      final uri = Uri.tryParse(v.contains('://') ? v : 'https://$v');
      return uri != null && uri.host.contains('.')
          ? null
          : 'Enter a web address, e.g. instagram.com/yourshop';
    case InputKind.text:
    case InputKind.multiline:
      return null;
  }
}

// --- Shared building blocks ---------------------------------------------------------------------

const _contactOptions = [
  'Phone call',
  'WhatsApp',
  'Email',
  'Website',
  'Instagram',
  'Facebook',
  'LinkedIn',
];

List<Question> _contactFields(String id) => [
  TextQuestion(
    '$id.phone',
    'Phone',
    hint: '+91 98765 43210',
    kind: InputKind.phone,
    required: true,
    showIf: _picked(id, ['Phone call']),
  ),
  TextQuestion(
    '$id.whatsapp',
    'WhatsApp number',
    hint: 'Can be the same as your phone',
    kind: InputKind.phone,
    required: true,
    showIf: _picked(id, ['WhatsApp']),
  ),
  TextQuestion(
    '$id.email',
    'Email',
    hint: 'hello@yourbusiness.com',
    kind: InputKind.email,
    required: true,
    showIf: _picked(id, ['Email']),
  ),
  TextQuestion(
    '$id.website',
    'Website',
    hint: 'yourbusiness.com',
    kind: InputKind.url,
    required: true,
    showIf: _picked(id, ['Website']),
  ),
  TextQuestion(
    '$id.instagram',
    'Instagram',
    hint: 'instagram.com/yourbusiness',
    kind: InputKind.url,
    required: true,
    showIf: _picked(id, ['Instagram']),
  ),
  TextQuestion(
    '$id.facebook',
    'Facebook',
    hint: 'facebook.com/yourbusiness',
    kind: InputKind.url,
    required: true,
    showIf: _picked(id, ['Facebook']),
  ),
  TextQuestion(
    '$id.linkedin',
    'LinkedIn',
    hint: 'linkedin.com/in/you',
    kind: InputKind.url,
    required: true,
    showIf: _picked(id, ['LinkedIn']),
  ),
  TextQuestion(
    '$id.other',
    'Other contact',
    hint: 'How else can people reach you?',
    required: true,
    showIf: _picked(id, [otherChip]),
  ),
];

const _hoursOptions = [
  'Monday–Friday',
  'Monday–Saturday',
  'All seven days',
  'Custom hours',
  'Appointment only',
  "Don't show hours",
];

List<Question> _hours(String id) => [
  ChipQuestion(id, 'Open', options: _hoursOptions, other: false),
  TextQuestion(
    '$id.times',
    'Hours',
    hint: 'e.g. 10am–8pm, closed on Tuesdays',
    showIf: _picked(id, [
      'Monday–Friday',
      'Monday–Saturday',
      'All seven days',
      'Custom hours',
    ]),
  ),
];

// --- Purposes ----------------------------------------------------------------------------------

const _business = [
  OnboardingStep('What type of business do you run?', [
    ChipQuestion(
      'business.type',
      'Type of business',
      required: true,
      options: [
        'Retail shop',
        'Clothing or fashion',
        'Jewellery',
        'Salon or spa',
        'Healthcare or clinic',
        'Real estate',
        'Professional services',
        'Digital agency',
        'Construction',
        'Education or coaching',
        'Home services',
        'Travel or tourism',
        'Fitness or gym',
      ],
    ),
  ]),
  OnboardingStep('Tell us about your business', [
    TextQuestion(
      'business.name',
      'Business name',
      hint: 'e.g. Sugar Loaf Bakery',
      required: true,
    ),
    TextQuestion(
      'business.about',
      'What you do',
      hint: 'A sentence or two about your business',
      kind: InputKind.multiline,
      required: true,
    ),
    TextQuestion(
      'business.offer',
      'Main products or services',
      hint: 'e.g. Custom cakes, sourdough, cookies',
    ),
    TextQuestion('business.tagline', 'Tagline'),
  ]),
];

final _purposes = <Purpose>[
  Purpose(
    'Business page',
    'Shops, services and local businesses',
    'Blue-Storefront-App-Icon',
    [
      ..._business,
      OnboardingStep(
        'How can customers contact you?',
        [
          ChipQuestion(
            'business.contact',
            'Contact by',
            multi: true,
            options: _contactOptions,
          ),
          ..._contactFields('business.contact'),
        ],
        subtitle:
            'Pick all that apply. Only what you fill in appears on your page.',
      ),
      OnboardingStep('Where and when can customers find you?', [
        ChipQuestion(
          'business.where',
          'Location',
          other: false,
          options: [
            'I have a physical store',
            'I work from an office',
            "I serve customers at their location",
            'I operate online',
            'I have multiple branches',
          ],
        ),
        TextQuestion(
          'business.address',
          'Address',
          hint: 'Street, area, city',
          kind: InputKind.multiline,
          required: true,
          showIf: _picked('business.where', [
            'I have a physical store',
            'I work from an office',
            'I have multiple branches',
          ]),
        ),
        TextQuestion(
          'business.maps',
          'Google Maps link',
          kind: InputKind.url,
          showIf: _picked('business.where', [
            'I have a physical store',
            'I work from an office',
            'I have multiple branches',
          ]),
        ),
        TextQuestion(
          'business.areas',
          'Areas you serve',
          hint: 'e.g. Baner, Aundh and Wakad',
          showIf: _picked('business.where', [
            "I serve customers at their location",
          ]),
        ),
        ..._hours('business.hours'),
      ]),
      OnboardingStep("What's the most important thing customers should do?", [
        ChipQuestion(
          'business.action',
          'Main action',
          options: [
            'Call my business',
            'Message on WhatsApp',
            'Visit my store',
            'View products or services',
            'Request a quote',
            'Book an appointment',
            'Visit my website',
          ],
        ),
        TextQuestion(
          'business.booking',
          'Booking link',
          hint: 'Where people book, e.g. calendly.com/you',
          kind: InputKind.url,
          showIf: _picked('business.action', ['Book an appointment']),
        ),
        _needed(
          'business.action.phone',
          'Phone',
          InputKind.phone,
          actionId: 'business.action',
          option: 'Call my business',
          given: _hasContact('business.contact', 'Phone call'),
        ),
        _needed(
          'business.action.whatsapp',
          'WhatsApp number',
          InputKind.phone,
          actionId: 'business.action',
          option: 'Message on WhatsApp',
          given: _hasContact('business.contact', 'WhatsApp'),
        ),
        _needed(
          'business.action.website',
          'Website',
          InputKind.url,
          actionId: 'business.action',
          option: 'Visit my website',
          given: _hasContact('business.contact', 'Website'),
        ),
        _needed(
          'business.action.address',
          'Store address',
          InputKind.multiline,
          actionId: 'business.action',
          option: 'Visit my store',
          given: _hasText(['business.address']),
        ),
      ], subtitle: 'It becomes the main button on your page.'),
    ],
  ),
  Purpose(
    'Restaurant menu',
    'Restaurants, cafés and bakeries',
    'Minimal-Coral-Cutlery-Icon',
    [
      OnboardingStep('What kind of food business is it?', [
        ChipQuestion(
          'food.type',
          'Type of food business',
          required: true,
          options: [
            'Restaurant',
            'Café or coffee shop',
            'Bakery',
            'Fast food',
            'Food truck',
            'Cloud kitchen',
            'Vegetarian restaurant',
            'Fine dining',
            'Catering service',
            'Juice or dessert shop',
          ],
        ),
      ]),
      OnboardingStep('Tell us about your place', [
        TextQuestion(
          'food.name',
          'Name',
          hint: 'e.g. The Daily Brew',
          required: true,
        ),
        TextQuestion(
          'food.about',
          'Short description',
          hint: 'What makes it special',
          kind: InputKind.multiline,
          required: true,
        ),
        ChipQuestion(
          'food.cuisine',
          'Cuisine',
          multi: true,
          options: [
            'Indian',
            'Italian',
            'Chinese',
            'Mexican',
            'Japanese',
            'Continental',
            'Rajasthani',
            'South Indian',
            'Bakery and desserts',
            'Multi-cuisine',
          ],
        ),
      ]),
      OnboardingStep(
        'What goes on your menu?',
        [
          ChipQuestion(
            'food.menu',
            'Menu sections',
            multi: true,
            other: false,
            options: [
              'Food',
              'Drinks',
              'Bestsellers',
              "Today's specials",
              'Special offers',
            ],
          ),
          ChipQuestion(
            'food.prices',
            'Prices',
            other: false,
            options: ['Show prices', 'No prices'],
          ),
          TextQuestion(
            'food.items',
            'Menu items',
            hint: 'One per line, e.g. Cappuccino – ₹180',
            kind: InputKind.multiline,
          ),
        ],
        subtitle:
            'Add as much or as little as you like. You can add photos of the menu at the end.',
      ),
      OnboardingStep('Where and when are you open?', [
        TextQuestion(
          'food.phone',
          'Phone',
          hint: '+91 98765 43210',
          kind: InputKind.phone,
        ),
        TextQuestion('food.whatsapp', 'WhatsApp number', kind: InputKind.phone),
        TextQuestion(
          'food.address',
          'Address',
          hint: 'Street, area, city',
          kind: InputKind.multiline,
        ),
        TextQuestion('food.maps', 'Google Maps link', kind: InputKind.url),
        ..._hours('food.hours'),
      ]),
      OnboardingStep('What can customers do?', [
        ChipQuestion(
          'food.actions',
          'Customer actions',
          multi: true,
          other: false,
          options: [
            'View the menu',
            'Call to order',
            'Order on WhatsApp',
            'Book a table',
            'Order online',
            'Get directions',
          ],
        ),
        TextQuestion(
          'food.booking',
          'Table booking link',
          hint: 'e.g. your Zomato or Dineout page',
          kind: InputKind.url,
          required: true,
          showIf: _picked('food.actions', ['Book a table']),
        ),
        TextQuestion(
          'food.ordering',
          'Online ordering link',
          hint: 'e.g. your Swiggy or Zomato page',
          kind: InputKind.url,
          required: true,
          showIf: _picked('food.actions', ['Order online']),
        ),
        _needed(
          'food.actions.phone',
          'Phone for orders',
          InputKind.phone,
          actionId: 'food.actions',
          option: 'Call to order',
          given: _hasText(['food.phone']),
        ),
        _needed(
          'food.actions.whatsapp',
          'WhatsApp number',
          InputKind.phone,
          actionId: 'food.actions',
          option: 'Order on WhatsApp',
          given: _hasText(['food.whatsapp']),
        ),
        _needed(
          'food.actions.maps',
          'Address or Google Maps link',
          InputKind.text,
          actionId: 'food.actions',
          option: 'Get directions',
          given: _hasText(['food.address', 'food.maps']),
        ),
      ]),
    ],
  ),
  Purpose(
    'Business card',
    'Your professional contact details',
    'Pastel-Purple-Profile-Card-Icon',
    [
      OnboardingStep('Who is the card for?', [
        ChipQuestion(
          'card.role',
          'Card for',
          required: true,
          options: [
            'Business owner',
            'Employee',
            'Freelancer',
            'Consultant',
            'Sales professional',
            'Real estate agent',
            'Doctor or healthcare',
            'Designer or developer',
            'Student',
          ],
        ),
      ]),
      OnboardingStep('Your details', [
        TextQuestion('card.name', 'Full name', required: true),
        TextQuestion('card.title', 'Job title', hint: 'e.g. Founder'),
        TextQuestion('card.company', 'Company'),
        TextQuestion(
          'card.intro',
          'Short introduction',
          kind: InputKind.multiline,
        ),
      ]),
      OnboardingStep('How can people reach you?', [
        ChipQuestion(
          'card.contact',
          'Contact by',
          multi: true,
          options: _contactOptions,
        ),
        ..._contactFields('card.contact'),
      ], subtitle: 'Only what you fill in appears on your card.'),
      OnboardingStep('What should people do after scanning?', [
        ChipQuestion(
          'card.actions',
          'Visitor actions',
          multi: true,
          other: false,
          options: [
            'Save my contact',
            'Call me',
            'WhatsApp me',
            'Email me',
            'Visit my website',
            'Connect on LinkedIn',
            'Book a meeting',
            'View my work',
          ],
        ),
        TextQuestion(
          'card.booking',
          'Meeting booking link',
          hint: 'e.g. calendly.com/you',
          kind: InputKind.url,
          required: true,
          showIf: _picked('card.actions', ['Book a meeting']),
        ),
        TextQuestion(
          'card.work',
          'Link to your work',
          hint: 'Portfolio or website',
          kind: InputKind.url,
          required: true,
          showIf: _picked('card.actions', ['View my work']),
        ),
        _needed(
          'card.actions.phone',
          'Phone',
          InputKind.phone,
          actionId: 'card.actions',
          option: 'Call me',
          given: _hasContact('card.contact', 'Phone call'),
        ),
        _needed(
          'card.actions.whatsapp',
          'WhatsApp number',
          InputKind.phone,
          actionId: 'card.actions',
          option: 'WhatsApp me',
          given: _hasContact('card.contact', 'WhatsApp'),
        ),
        _needed(
          'card.actions.email',
          'Email',
          InputKind.email,
          actionId: 'card.actions',
          option: 'Email me',
          given: _hasContact('card.contact', 'Email'),
        ),
        _needed(
          'card.actions.website',
          'Website',
          InputKind.url,
          actionId: 'card.actions',
          option: 'Visit my website',
          given: _hasContact('card.contact', 'Website'),
        ),
        _needed(
          'card.actions.linkedin',
          'LinkedIn',
          InputKind.url,
          actionId: 'card.actions',
          option: 'Connect on LinkedIn',
          given: _hasContact('card.contact', 'LinkedIn'),
        ),
      ]),
    ],
  ),
  Purpose(
    'Event or invitation',
    'Weddings, parties and events',
    'Minimalist-Pink-Calendar-App-Icon',
    [
      OnboardingStep('What are you creating an invitation for?', [
        ChipQuestion(
          'event.type',
          'Event type',
          required: true,
          options: [
            'Wedding',
            'Engagement',
            'Birthday party',
            'Anniversary',
            'Baby shower',
            'Housewarming',
            'Religious ceremony',
            'Festival or celebration',
            'Corporate event',
            'Conference or seminar',
            'Workshop',
            'Concert or live show',
            'School or college event',
            'Community gathering',
          ],
        ),
      ]),
      OnboardingStep('About the event', [
        TextQuestion(
          'event.title',
          'Event name',
          hint: 'e.g. Asha & Rohan’s Wedding',
          required: true,
        ),
        TextQuestion('event.host', 'Hosted by', required: true),
        TextQuestion(
          'event.date',
          'Date',
          hint: 'e.g. Saturday, 14 February 2027',
          required: true,
        ),
        TextQuestion('event.time', 'Time', hint: 'e.g. 7pm onwards'),
        TextQuestion(
          'event.message',
          'Invitation message',
          kind: InputKind.multiline,
        ),
      ]),
      OnboardingStep('Where is it?', [
        ChipQuestion(
          'event.format',
          'Format',
          other: false,
          options: ['In person', 'Online', 'Hybrid', 'Not decided yet'],
        ),
        TextQuestion(
          'event.venue',
          'Venue',
          hint: 'Venue name and address',
          kind: InputKind.multiline,
          required: true,
          showIf: _picked('event.format', ['In person', 'Hybrid']),
        ),
        TextQuestion(
          'event.maps',
          'Google Maps link',
          kind: InputKind.url,
          showIf: _picked('event.format', ['In person', 'Hybrid']),
        ),
        TextQuestion(
          'event.online',
          'Online meeting link',
          kind: InputKind.url,
          showIf: _picked('event.format', ['Online', 'Hybrid']),
        ),
      ]),
      OnboardingStep('Style and guest options', [
        ChipQuestion(
          'event.style',
          'Invitation style',
          options: [
            'Simple details',
            'Elegant',
            'Traditional',
            'Modern',
            'Formal corporate',
            'Fun party',
            'Photo-based',
          ],
        ),
        ChipQuestion(
          'event.guests',
          'Guests can',
          multi: true,
          other: false,
          options: [
            'RSVP by WhatsApp or call',
            'Add it to their calendar',
            'Get directions',
            'Contact the host',
            'See the schedule',
            'See the dress code',
          ],
        ),
        TextQuestion(
          'event.rsvp',
          'RSVP / host number',
          hint: '+91 98765 43210',
          kind: InputKind.phone,
          required: true,
          showIf: _picked('event.guests', [
            'RSVP by WhatsApp or call',
            'Contact the host',
          ]),
        ),
        TextQuestion(
          'event.schedule',
          'Schedule',
          hint: 'One per line, e.g. 7pm – Welcome drinks',
          kind: InputKind.multiline,
          showIf: _picked('event.guests', ['See the schedule']),
        ),
        TextQuestion(
          'event.dress',
          'Dress code',
          showIf: _picked('event.guests', ['See the dress code']),
        ),
      ]),
    ],
  ),
  Purpose(
    'Product or catalog',
    'One product or a collection',
    'glossy-blue-document-appa-icon',
    [
      OnboardingStep('What are you showcasing?', [
        ChipQuestion(
          'product.category',
          'Category',
          required: true,
          options: [
            'Clothing and fashion',
            'Jewellery',
            'Electronics',
            'Food or packaged goods',
            'Beauty and skincare',
            'Home and furniture',
            'Handmade products',
            'Digital products',
            'Multiple products',
          ],
        ),
      ]),
      OnboardingStep('Tell us about it', [
        TextQuestion('product.name', 'Product or catalog name', required: true),
        TextQuestion('product.brand', 'Brand'),
        TextQuestion(
          'product.about',
          'Description',
          hint: 'What it is and why people love it',
          kind: InputKind.multiline,
          required: true,
        ),
        TextQuestion(
          'product.items',
          'Products and prices',
          hint: 'One per line, e.g. Silk scarf – ₹1,200',
          kind: InputKind.multiline,
        ),
      ]),
      OnboardingStep('What should customers do?', [
        ChipQuestion(
          'product.actions',
          'Customer actions',
          multi: true,
          other: false,
          options: [
            'View details',
            'Buy online',
            'Order on WhatsApp',
            'Call to order',
            'Find our store',
            'Request a quote',
          ],
        ),
        TextQuestion(
          'product.buy',
          'Shop link',
          kind: InputKind.url,
          required: true,
          showIf: _picked('product.actions', ['Buy online']),
        ),
        TextQuestion(
          'product.whatsapp',
          'WhatsApp number',
          kind: InputKind.phone,
          required: true,
          showIf: _picked('product.actions', ['Order on WhatsApp']),
        ),
        TextQuestion(
          'product.phone',
          'Phone',
          kind: InputKind.phone,
          required: true,
          showIf: _picked('product.actions', [
            'Call to order',
            'Request a quote',
          ]),
        ),
        TextQuestion(
          'product.store',
          'Store address',
          kind: InputKind.multiline,
          required: true,
          showIf: _picked('product.actions', ['Find our store']),
        ),
      ]),
    ],
  ),
  Purpose(
    'Portfolio',
    'Show your work to clients',
    'glossy-purple-star-app-icon',
    [
      OnboardingStep('What kind of portfolio do you need?', [
        ChipQuestion(
          'folio.type',
          'Portfolio for',
          required: true,
          options: [
            'Graphic designer',
            'UI/UX designer',
            'Web developer',
            'Photographer',
            'Videographer',
            'Artist or illustrator',
            'Writer',
            'Marketing professional',
            'Architect or interior designer',
            'Consultant',
            'Student',
          ],
        ),
      ]),
      OnboardingStep('About you', [
        TextQuestion('folio.name', 'Full name', required: true),
        TextQuestion(
          'folio.title',
          'Professional title',
          hint: 'e.g. Product designer',
        ),
        TextQuestion('folio.intro', 'Introduction', kind: InputKind.multiline),
      ]),
      OnboardingStep('What do you want to showcase?', [
        ChipQuestion(
          'folio.show',
          'Showcase',
          multi: true,
          options: [
            'Selected projects',
            'Case studies',
            'Services',
            'Work experience',
            'Education',
          ],
        ),
        TextQuestion(
          'folio.projects',
          'Projects',
          hint: 'One per line: title – what you did – link',
          kind: InputKind.multiline,
        ),
      ], subtitle: 'Add project images with photos at the end.'),
      OnboardingStep('How can people reach you?', [
        ChipQuestion(
          'folio.contact',
          'Contact by',
          multi: true,
          options: _contactOptions,
        ),
        ..._contactFields('folio.contact'),
      ]),
    ],
  ),
  Purpose(
    'I have a website',
    'A QR page that leads to your site',
    'gradient-qr-app-icon',
    [
      OnboardingStep(
        'Which website should people reach?',
        [
          TextQuestion(
            'site.url',
            'Website',
            hint: 'yourbusiness.com',
            kind: InputKind.url,
            required: true,
          ),
          ChipQuestion(
            'site.where',
            'Where will you use the QR?',
            multi: true,
            options: [
              'Business cards',
              'Packaging',
              'Menus',
              'Posters',
              'Social media',
            ],
          ),
          TextQuestion(
            'site.extra',
            'What else should the page show?',
            hint: 'e.g. our WhatsApp number and today’s offer',
            kind: InputKind.multiline,
          ),
        ],
        subtitle:
            "Your QR opens a Live QR page linking to your site, so you can change where it leads without reprinting.",
      ),
    ],
  ),
  Purpose(
    'Something else',
    'Tell us in your own words',
    'glossy-pastel-magic-sparkles-icon',
    [
      OnboardingStep('What should people see when they scan?', [
        ChipQuestion(
          'custom.kind',
          'Idea',
          options: [
            'A page for my shop',
            'A page for my service',
            'A property listing',
            'A fundraiser',
            'A course or resource',
            'A digital brochure',
          ],
        ),
        TextQuestion(
          'custom.about',
          'Describe it',
          hint: 'Include any details, links and actions you want people to see',
          kind: InputKind.multiline,
          required: true,
        ),
      ]),
    ],
  ),
];

List<Purpose> get purposes => _purposes;

/// Asked for every purpose, after its own questions.
const extrasStep = OnboardingStep('Anything else to include?', [
  ChipQuestion(
    'extras.style',
    'Design style',
    other: false,
    options: [
      'Minimal',
      'Modern',
      'Premium',
      'Playful',
      'Elegant',
      'Bold',
      'Traditional',
      'Let AI choose',
    ],
  ),
  TextQuestion('extras.colours', 'Colours', hint: 'e.g. burgundy and gold'),
  TextQuestion(
    'extras.notes',
    'Anything else',
    hint: 'Extra details or special instructions',
    kind: InputKind.multiline,
  ),
], subtitle: 'All optional. You can also add your logo and photos here.');

/// The answer to [q] as prompt text ('' if unanswered or hidden). "Other" becomes the typed text.
String answerText(Question q, Answers a) {
  if (!q.visible(a)) return '';
  return switch (q) {
    ChipQuestion() => [
      for (final p in a.picked(q.id))
        if (p != otherChip)
          p
        else if (a.otherText(q.id).isNotEmpty)
          a.otherText(q.id),
    ].join(', '),
    TextQuestion() => a.text(q.id),
  };
}

/// Turns the answers into the prompt the page is generated from. Only answered questions appear.
String describe(Purpose purpose, Answers a) => [
  'Page type: ${purpose.label}',
  for (final step in [...purpose.steps, extrasStep])
    for (final q in step.questions)
      if (answerText(q, a) case final value when value.isNotEmpty)
        value.contains('\n') ? '${q.label}:\n$value' : '${q.label}: $value',
].join('\n');
