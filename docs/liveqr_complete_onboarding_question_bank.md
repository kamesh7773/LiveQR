# Live QR — Complete Dynamic Onboarding Question Bank & UI Specification

**Purpose:** Complete product and UI specification for Live QR's conditional onboarding flow.  
**Goal:** Collect enough accurate information to generate a polished, useful, mobile-friendly page and a dynamic QR code without overwhelming the user.  
**Core principle:** Users describe what they want; Live QR asks relevant follow-up questions, creates the page, and publishes it behind a stable QR destination.

---

## 1. Product Vision

Live QR helps users create an online page even when they do not already have a website. A user chooses what they want to create, describes their needs, answers a small number of relevant questions, reviews the generated page, and publishes it with a dynamic QR code.

The primary experience:

1. Choose a purpose.
2. Answer relevant questions using chips, short fields, uploads, or free text.
3. Add optional information or skip it.
4. Review the collected information.
5. Generate the page using AI.
6. Edit and preview the page.
7. Publish it and receive a QR code.
8. Update the published page later without changing the QR code.

**This document is the complete question bank, not one giant form.** Show only the questions relevant to the selected use case.

## 2. Core UX Principles

- Make the experience feel like a conversation with an AI designer, not a long registration form.
- Use chips for common answers.
- Offer **Other** or **Something else** wherever users may need a custom answer.
- When **Other** is selected, show a text input.
- Mark optional questions clearly and provide **Skip for now**.
- Provide a free-text area for extra information at any step.
- Extract facts from the original description to avoid asking users to enter the same information twice.
- Ask for confirmation of important facts rather than inventing them.
- Show only follow-up questions relevant to the selected answers.
- Preserve answers when users go back.
- Let users edit answers before generating the page.
- Support image and document uploads where relevant.
- Keep the primary action clear and visible.
- Use responsive, accessible UI with readable type, clear labels, adequate tap targets, keyboard support, and reduced-motion support.
- Do not make optional information a blocker.
- Explain when a feature requires a link or integration that is not configured.

## 3. End-to-End User Flow

1. **Choose a purpose.** Business page, restaurant menu, digital business card, event/invitation, product/catalog, portfolio, existing URL, or something else.
2. **Ask conditional questions.** The selected category determines the questions shown. Further answers may reveal or hide additional fields.
3. **Add optional details.** Logo, photos, documents, extra links, style preferences, and special instructions.
4. **Review.** Show a compact summary with edit actions and clear indicators for confirmed or missing optional details.
5. **Generate.** AI creates a page specification using supported components. Validate output and do not invent business facts.
6. **Preview and edit.** Users can make direct edits or use conversational instructions.
7. **Publish and create the QR.** Publish behind a stable Live QR URL. Later page updates must not require a new QR code.

---

## 4. Purpose Selection Screen

### Heading
**What would you like to create?**

### Supporting text
“Tell us what people should see when they scan your QR code.”

### Purpose cards/chips

| Purpose | Description | Question branch |
|---|---|---|
| Business page | Shops, services, companies and local businesses | Section 5 |
| Restaurant menu | Restaurants, cafés, bakeries and food businesses | Section 6 |
| Digital business card | Professional contact details | Section 7 |
| Event or invitation | Celebrations, meetings, conferences and events | Section 8 |
| Product page or catalog | A product or collection of products | Section 9 |
| Portfolio | Creators and professionals showcasing work | Section 10 |
| I have a website | Create a QR for an existing URL | Section 11 |
| Something else | A custom use case | Section 12 |

### Optional free-text input
**Label:** “Anything else you'd like us to know? (Optional)”  
**Placeholder:** “Example: I want customers to view my services and contact me on WhatsApp.”

### Behavior
- User selects one primary purpose.
- If **Something else** is selected, free text becomes the primary input.
- If the user already described their purpose, preselect or recommend a category but allow changes.
- Do not force a template choice at this stage. Templates are optional design shortcuts, not the core product.
- Provide a clear Continue action.
- Preserve any description already entered.

---

## 5. Business Page Question Bank

For local businesses, shops, salons, agencies, consultants, repair services, and other companies.

### 5.1 Business type

**Question:** “What type of business do you run?”

Chips:
- Retail shop
- Clothing or fashion
- Jewellery
- Salon or spa
- Healthcare or clinic
- Real estate
- Professional services
- Digital agency
- Construction
- Education or coaching
- Home services
- Travel or tourism
- Fitness or gym
- Other

If **Other** is selected, ask “What type of business do you run?” with a text input.

### 5.2 Basic business information

| Field | Required? | Input / behavior |
|---|---|---|
| Business name | Yes | Text input |
| Short business description | Yes | Multiline text; may be extracted from initial description |
| Main products or services | Recommended | Multiple chips plus custom input |
| Business logo | Optional | Image upload |
| Cover or banner image | Optional | Image upload |
| Business tagline | Optional | Text input |
| Year established | Optional | Year selector or text input |
| Website | Optional | URL input |
| Social media links | Optional | Add one or more links |

Example products/services chips for a clothing shop: Men's wear, Women's wear, Ethnic wear, Accessories, Other. Suggestions should adapt to business type.

### 5.3 Contact information

**Question:** “How can customers contact you?”

Allow multiple selections:
- Phone call
- WhatsApp
- Email
- Contact form
- Website
- Instagram
- Facebook
- LinkedIn
- Other

Reveal only fields related to selected options:

| Selected option | Follow-up field |
|---|---|
| Phone call | Phone number with country code |
| WhatsApp | WhatsApp number; offer “Use the same number” |
| Email | Business email |
| Contact form | Select information the form should collect |
| Website | Website URL |
| Instagram | Profile URL or username |
| Facebook | Page URL |
| LinkedIn | Page or profile URL |
| Other | Custom contact method and relevant details |

Optional contact form fields: Name, Email, Phone, Message, Enquiry type. Collect only information the business needs.

### 5.4 Business location

**Question:** “Where can customers find you?”

Chips:
- I have a physical store
- I work from an office
- I serve customers at their location
- I operate online
- I have multiple branches

For a physical location or office, ask:
- Country
- State or region
- City
- Full street address
- Postal code, if applicable
- Google Maps location or map link
- Branch name, if there are multiple locations

Provide **Select location on map** through a supported map picker or accept a Google Maps link. Do not require a Maps URL if the user can enter and confirm the address another way.

For service-area businesses, ask which cities or areas they serve. For online-only businesses, allow location to be skipped.

### 5.5 Opening hours

**Question:** “When are you open?”

Chips:
- Monday–Friday
- Monday–Saturday
- All seven days
- Custom hours
- Appointment only
- Don't display hours

If hours are displayed, support per-day opening and closing times, closed days, breaks, and multiple time ranges per day when needed.

### 5.6 Primary customer action

**Question:** “What's the most important action for your customers?”

Chips:
- Call my business
- Message on WhatsApp
- Visit my store
- View products or services
- Request a quote
- Book an appointment
- Send an enquiry
- Visit my website
- Other

Use the answer to prioritize the main call-to-action. Examples: construction business → Request a quote; salon → Book an appointment; retail shop → Visit my store or view products.

### 5.7 Optional business details

Place these in a collapsed **Add more details** section:
- Services and descriptions
- Product highlights
- Pricing or starting prices
- Offers and promotions
- Customer testimonials supplied by the owner
- Certifications or awards
- Frequently asked questions
- Additional locations
- Languages supported
- Preferred page language
- Design preference

Do not fabricate reviews, awards, certifications, hours, or prices.

---

## 6. Restaurant Menu Question Bank

For restaurants, cafés, bakeries, food trucks, cloud kitchens, bars, and caterers.

### 6.1 Food business type

**Question:** “What kind of food business is it?”

Chips:
- Restaurant
- Café or coffee shop
- Bakery
- Fast food
- Food truck
- Cloud kitchen
- Vegetarian restaurant
- Fine dining
- Catering service
- Juice or dessert shop
- Other

### 6.2 Restaurant details

| Field | Required? |
|---|---|
| Restaurant name | Yes |
| Short description | Yes |
| Cuisine type | Recommended |
| Logo | Optional |
| Cover image | Optional |
| Phone number | Recommended |
| WhatsApp number | Optional |
| Physical address | Recommended |
| Google Maps location | Recommended for physical venues |
| Opening hours | Recommended |
| Website and social links | Optional |

Cuisine chips: Indian, Italian, Chinese, Mexican, Japanese, Continental, Rajasthani, South Indian, Bakery and desserts, Multi-cuisine, Other.

### 6.3 Menu content

**Question:** “What do you want your menu to include?”

Chips:
- Food menu
- Drinks menu
- Food and drinks
- Special offers
- Bestsellers
- Today's specials
- Full menu with prices
- Menu without prices

Allow users to add menu items manually, add multiple items, or upload a menu image/PDF for extraction and review.

Each menu item can include:
- Item name
- Category
- Description
- Price and currency
- Food photo
- Dietary labels, such as vegetarian or vegan
- Allergen information, if supplied
- Availability, such as sold out or available

Example categories: Starters, Main Course, Pizza, Burgers, Desserts, Hot Drinks, Cold Drinks, Combos. Categories should adapt to cuisine and the owner's menu.

### 6.4 Customer actions

**Question:** “What can customers do?”

Chips:
- View menu only
- Call to order
- Order through WhatsApp
- Request a table
- Book a table
- Place an online order
- View delivery options
- Get directions
- Contact us

Only show booking or ordering details if selected and the required functionality or external link is available.

### 6.5 Optional restaurant details

- Average price range
- Dine-in, takeaway, and delivery
- Delivery areas
- Online ordering link
- Reservation link
- Special dietary options
- Restaurant gallery
- Catering services
- Happy-hour or seasonal offers
- Languages supported

---

## 7. Digital Business Card Question Bank

For individuals who want to share professional identity and contact details using a QR code.

### 7.1 Professional role

**Question:** “Who is the card for?”

Chips:
- Business owner
- Employee
- Freelancer
- Consultant
- Sales professional
- Real estate agent
- Doctor or healthcare professional
- Designer or developer
- Student
- Other

### 7.2 Personal and professional details

| Field | Required? |
|---|---|
| Full name | Yes |
| Job title or role | Recommended |
| Company or organization | Optional |
| Profile photo | Optional |
| Short professional introduction | Recommended |
| Phone number | Optional |
| Work email | Optional |
| WhatsApp | Optional |
| Website | Optional |
| LinkedIn | Optional |
| Other social profiles | Optional |

### 7.3 Visitor actions

**Question:** “What should people do after scanning?”

Chips:
- Save my contact
- Call me
- WhatsApp me
- Email me
- Visit my website
- Connect on LinkedIn
- Book a meeting
- Download my résumé
- View my work
- Other

Behavior:
- For **Save my contact**, generate a downloadable contact card (vCard) from confirmed details.
- For **Book a meeting**, ask for a booking URL unless Live QR provides native scheduling.
- For **Download my résumé**, request a résumé/CV file or link.

### 7.4 Optional professional information

- Office address
- Google Maps location
- Business hours
- Services offered
- Certifications
- Résumé or CV upload
- Portfolio link
- Company logo
- Preferred professional style
- Additional contact numbers

Never require a personal address or office location for a digital business card.

---

## 8. Event or Invitation Question Bank

For weddings, engagements, birthdays, anniversaries, baby showers, housewarmings, religious ceremonies, corporate events, conferences, workshops, concerts, school events, and community gatherings.

### 8.1 Event type

**Question:** “What are you creating an invitation for?”

Chips:
- Wedding
- Engagement
- Birthday party
- Anniversary
- Baby shower
- Housewarming
- Religious ceremony
- Festival or celebration
- Corporate event
- Conference or seminar
- Workshop
- Concert or live show
- School or college event
- Community gathering
- Other

If **Other** is selected, let the user enter a custom event type.

### 8.2 Event information

| Field | Required? | Notes |
|---|---|---|
| Event name or title | Yes | Text |
| Host or organizer name | Yes | Text |
| Short invitation message | Recommended | Multiline text |
| Event date | Yes for scheduled events | Date picker |
| Start time | Recommended | Time picker |
| End time | Optional | Time picker |
| Time zone | When relevant | Especially online or cross-region events |
| Venue name | Required for in-person events | Text |
| Full venue address | Required for in-person events | Address input |
| Google Maps link | Recommended | Optional when a map picker is used |
| Online meeting link | Required for online events | URL |
| Cover photo or invitation artwork | Optional | Upload |
| RSVP deadline | Optional | Date picker |

### 8.3 Event format

**Question:** “What is the event format?”

Chips:
- In person
- Online
- Hybrid
- Not decided yet

Conditional behavior:
- In person → collect venue and address.
- Online → collect event or meeting URL when available.
- Hybrid → collect both venue and online details.
- Not decided yet → allow the user to continue and add details later.

### 8.4 Invitation style

**Question:** “What type of invitation experience do you want?”

Chips:
- Simple event details
- Elegant invitation
- Traditional invitation
- Modern invitation
- Formal corporate invite
- Fun party invite
- Photo-based invitation
- Other

These options guide visual design only; they must not alter event facts.

### 8.5 Guest interaction

**Question:** “What should guests be able to do?”

Chips:
- View event details
- RSVP yes or no
- Confirm number of guests
- Add event to calendar
- Get directions
- Contact the host
- View the schedule
- View dress code
- View gift or registry information
- Other

If RSVP is selected, ask which fields are needed:
- Guest name required?
- Email or phone required?
- Can guests bring additional people?
- Maximum additional guests allowed?
- Meal preference needed?
- Accessibility or special requirements?
- RSVP deadline?

Keep guest questions configurable and collect only what the organizer needs.

### 8.6 Optional event details

- Event agenda or schedule
- Dress code
- Speakers or performers
- Ticket or registration link
- Event pricing
- Sponsor logos
- Gift registry
- Accommodation information
- Parking information
- Event contact details
- Multiple event dates or sessions

Event-specific examples:
- Wedding → ceremony and reception times, hosts, schedule, RSVP, directions.
- Conference → agenda, speakers, registration, venue details.
- Birthday → host, date, venue, RSVP, optional photos.
- Religious ceremony → ceremony details, schedule, venue, optional dress guidance.

---

## 9. Product Page or Catalog Question Bank

For retail products, handmade goods, electronics, jewellery, fashion, packaging, and scannable product information pages.

### 9.1 Product category

**Question:** “What are you showcasing?”

Chips:
- Clothing and fashion
- Jewellery
- Electronics
- Food or packaged goods
- Beauty and skincare
- Home and furniture
- Handmade products
- Digital products
- Multiple products
- Other

### 9.2 Product information

| Field | Required? |
|---|---|
| Product or catalog name | Yes |
| Brand or business name | Recommended |
| Product description | Yes |
| Product images | Recommended |
| Price and currency | Optional |
| Product category | Recommended |
| Product variants | Optional |
| SKU or product code | Optional |
| Stock availability | Optional |
| Website or product link | Optional |
| Instructions or specifications | Depends on product |

For a single product, collect that product's details. For a catalog, support multiple products, a product list upload, or supported file import.

### 9.3 Customer actions

**Question:** “What should customers do?”

Chips:
- View product details
- Buy online
- Contact us to order
- Order on WhatsApp
- Find a nearby store
- Download product brochure
- View specifications
- Request a quote
- Other

Request the corresponding purchase URL, WhatsApp number, store location, brochure, or enquiry details only when relevant.

### 9.4 Optional product details

- Materials and ingredients
- Size and colour options
- Care instructions
- Usage instructions
- Warranty details
- Certifications
- Manufacturing information
- Expiry or batch information, when applicable
- Product documents
- Related products
- Shipping and returns policy

Only display fields relevant to the product category.

---

## 10. Portfolio Question Bank

For designers, developers, photographers, artists, consultants, creators, and freelancers.

### 10.1 Portfolio type

**Question:** “What kind of portfolio do you need?”

Chips:
- Graphic designer
- UI/UX designer
- Web developer
- Photographer
- Videographer
- Artist or illustrator
- Writer
- Marketing professional
- Architect or interior designer
- Consultant
- Student portfolio
- Other

### 10.2 Profile information

- Full name
- Professional title
- Introduction
- Profile photo
- Location, optional
- Email and phone, optional
- Social links
- Website, optional
- Résumé or CV, optional

### 10.3 What to showcase

**Question:** “What do you want to showcase?”

Chips:
- Selected projects
- All my work
- Case studies
- Services
- Client testimonials
- Certifications
- Work experience
- Education
- Awards
- Other

Each project can include:
- Project title
- Short description
- Cover image
- Gallery or supporting images
- Project URL
- Role and contribution
- Tools or technologies used
- Project date
- Results or outcomes, if supplied

### 10.4 Visitor actions

**Question:** “What should visitors do?”

Chips:
- Contact me
- Hire me
- Request a quote
- Book a consultation
- Download my résumé
- View my work
- Follow my social profiles
- Other

### 10.5 Optional portfolio preferences

- Preferred visual style
- Primary colour
- Languages
- Featured project
- Client or employer information
- Availability for work
- Testimonials supplied by the user

---

## 11. Existing Website URL Question Bank

This branch should be short because the user already has a destination.

### 11.1 Website URL

**Question:** “What website should your QR code open?”
- URL input — required.
- Validate the URL and provide a helpful error for invalid input.

### 11.2 QR destination type

**Question:** “What kind of QR do you want?”

Chips:
- Open my website
- Open a specific page
- Create a QR landing page linking to my website
- Other

### 11.3 Where will you use the QR?

Chips:
- Business cards
- Packaging
- Menus
- Posters
- Social media
- Other

If the user wants a landing page, ask what additional content or actions it should include.

**Technical distinction:** A QR code pointing directly to an external URL cannot be redirected by Live QR unless the code points to a Live QR-managed URL. Clearly explain whether the QR is dynamic.

---

## 12. Something Else — Custom Use Case

Do not force a custom use case into an unsuitable category.

### Primary question
**“Tell us what you want people to see when they scan your QR.”**

Suggested chips:
- A page for my shop
- A page for my service
- A property listing
- A donation or fundraising page
- A course or educational resource
- A digital brochure
- A booking or enquiry page
- Something else

### Free-text input
**Placeholder:** “Describe what you want to create. Include any details, links, images, or actions you want people to see.”

### AI behavior
1. Classify the requested use case.
2. Extract known details from the description.
3. Identify only essential missing details.
4. Ask conditional follow-up questions.
5. Use supported page structures and components.
6. If the request is unsupported, explain available alternatives rather than silently generating an unsupported experience.

---

## 13. Global Optional Details

Every branch should offer an **Add more details** area. This is optional and must not block progress.

### Suggested input
**Label:** “Anything else to include?”  
**Placeholder:** “Add extra details, links, images, or special instructions for your page.”

### Optional additions
- Logo, cover image, and gallery
- Additional descriptions
- Extra links
- Preferred page language
- Preferred colours
- Design style
- Existing documents or images
- Special instructions for AI
- Additional calls to action

### Upload behavior
- Preview selected files.
- Show file names and upload progress.
- Allow removal or replacement.
- Validate file type and size.
- Treat uploaded files as untrusted content.
- For menu or document extraction, show extracted information for user review before it is published.

### Design style chips
- Minimal
- Modern
- Premium
- Playful
- Elegant
- Bold
- Traditional
- Let AI choose

---

## 14. Review Before AI Generation

Before generation, show a compact summary of the collected details.

### Review sections
- Page purpose and type
- Business, person, event, or product details
- Contact methods
- Location or event venue, if relevant
- Main visitor action
- Uploaded assets
- Design preferences
- Missing optional details

Each section should have an **Edit** action.

### Information status
Distinguish between:
- Confirmed by the user
- Extracted from user-provided content and awaiting confirmation when important
- Optional information not provided
- Not applicable

### Primary action
**Generate my page**

### Review behavior
- Preserve answers when the user goes back.
- Allow users to edit any field.
- Do not invent missing facts.
- Explain which optional information is absent without blocking generation.
- Ask for confirmation when essential information is uncertain.
- Avoid implying a page has been published before the user publishes it.

---

## 15. AI Page Generation Requirements

AI should generate a structured page specification using supported components, not unrestricted HTML, JavaScript, or Flutter source code.

The page specification may define:
- Page type
- Theme and design tokens
- Section order
- Supported component types
- Text and user-provided business data
- Image references
- Action buttons
- Supported layout options

### AI quality rules
- Never invent phone numbers, addresses, prices, hours, reviews, awards, certifications, event dates, or product claims.
- Keep user-provided facts distinct from generated marketing copy.
- Validate model output against a schema.
- Allow only supported components and properties.
- Handle malformed model output safely.
- Preserve the last valid published version if generation or validation fails.
- Apply localized edits where possible.
- Ask for confirmation before publishing important changes.
- Treat user content and uploaded files as untrusted input.

---

## 16. Preview, Editing, Publishing, and Dynamic QR

### Preview and editing
Users should be able to:
- Preview the page on mobile and desktop sizes.
- Edit fields directly.
- Reorder or hide supported sections.
- Request edits using conversational instructions.
- Replace images and links.
- Review draft changes before publishing.

Example instructions:
- “Make the page more premium.”
- “Move the WhatsApp button to the top.”
- “Add our new offer.”
- “Change the opening hours.”
- “Add the event schedule.”

### Publishing model
1. Create or update a draft.
2. Validate the draft.
3. Preview the draft.
4. Publish it as a new immutable version.
5. Atomically update the current published-version pointer.
6. Invalidate relevant caches.
7. Keep previous versions available for rollback.

### Dynamic QR requirement
- Generate a stable Live QR URL for the page.
- The QR code resolves to the currently published version.
- Editing a draft must not change the public page until publishing.
- Updating the published page must not require reprinting the QR.
- A failed generation or publishing operation must not break the current published page.
- Visitors must be able to open the published page in a normal browser without installing the app or signing in.

---

## 17. UI Behavior and Interaction Specification

| Interaction | Expected behavior |
|---|---|
| Select a purpose | Opens the corresponding question branch |
| Select a chip | Saves the answer and reveals relevant fields |
| Multi-select chips | Allow multiple answers where supported |
| Select “Other” | Reveals a custom text input |
| Skip optional question | Moves forward without blocking |
| Add more details | Opens optional free text and uploads |
| Upload image/document | Show preview, progress, validation, remove and replace actions |
| Continue | Validate only required fields relevant to the current branch |
| Back | Preserve all entered answers |
| Change purpose | Explain incompatible fields and preserve reusable answers where possible |
| Generate page | Show progress, prevent accidental duplicate submissions, allow recovery on failure |
| Edit generated page | Support direct edits and AI instructions |
| Publish | Confirm publishing and show the stable QR destination |
| Update later | Publish a new version while keeping the same QR destination |

### Accessibility and responsive requirements
- Use clear field labels and helpful validation messages.
- Ensure sufficient contrast and readable font sizes.
- Use adequate touch targets.
- Support keyboard navigation.
- Support reduced motion.
- Keep the primary action easy to find.
- Avoid long scrolling screens with too many unrelated questions.
- Use a step indicator, but don't imply every branch has the same number of questions.
- Make chip states visually clear: selected, unselected, disabled, and custom-answer states.

---

## 18. Suggested Data Model for Answers

Use a flexible answer model so the backend can handle different page types without creating one enormous form schema.

Potential top-level objects:
- `purpose`
- `initial_description`
- `business_details`
- `contact_methods`
- `location_details`
- `opening_hours`
- `menu_details`
- `personal_profile`
- `event_details`
- `guest_interaction`
- `product_details`
- `portfolio_details`
- `existing_url_details`
- `design_preferences`
- `assets`
- `additional_instructions`
- `confirmation_state`

Implementation guidance:
- Store normalized data for fields that require searching, validation, analytics, or reuse.
- Use a versioned JSON structure for flexible page-specific answers.
- Validate inputs on the backend even if the UI already validates them.
- Store only information needed for the requested page and its functionality.
- Track which important extracted facts the user has confirmed.
- Do not store unnecessary sensitive information.
- Keep unpublished draft data separate from published page versions where practical.

---

## 19. Recommended Implementation Phases

### Phase 1 — Core MVP
- Purpose selection
- Business page branch
- Restaurant menu branch
- Digital business card branch
- Event/invitation branch
- Existing URL branch
- Free-text additional instructions
- Required-field validation
- Review and AI generation
- Public page rendering
- Stable dynamic QR publishing

### Phase 2 — More page types and editing
- Product catalog
- Portfolio
- Custom use cases
- Image/document extraction with user review
- AI conversational editing
- Version history and rollback
- Basic scan analytics

### Phase 3 — Advanced functionality
- Multiple business locations
- RSVP and guest management
- Native booking or ordering integrations where justified
- Advanced forms
- Custom domains and branding
- Team collaboration
- Subscription and billing
- Advanced analytics

Prioritize by actual user demand and reliability; do not implement every optional feature before the main creation flow works well.

---

## 20. Acceptance Checklist

### Onboarding
- [ ] User can begin without an existing website URL.
- [ ] User can select a purpose from chips/cards.
- [ ] Each purpose opens only relevant questions.
- [ ] “Other” allows custom input.
- [ ] Optional fields can be skipped.
- [ ] Extra information can be added at any stage.
- [ ] Previously supplied facts are not repeatedly requested.
- [ ] Answers persist when navigating back.
- [ ] Changing purpose handles incompatible answers clearly.

### Data quality
- [ ] Required fields are validated contextually.
- [ ] Phone numbers and URLs receive appropriate validation.
- [ ] Address and map details are user-confirmed.
- [ ] AI does not silently invent business or event facts.
- [ ] Uploaded document extraction is reviewed by the user.
- [ ] Sensitive or unnecessary data is not collected.

### Generation and publishing
- [ ] AI output is schema-validated.
- [ ] Generated pages use supported components.
- [ ] User can preview and edit before publishing.
- [ ] Publishing updates the current page version atomically.
- [ ] Failed generation leaves the previous published page intact.
- [ ] Stable QR destinations continue to work after page updates.
- [ ] Public pages work in a browser without app installation or login.

### UX
- [ ] The flow is responsive on desktop and mobile.
- [ ] The main action is clear at every step.
- [ ] The interface is not a giant form.
- [ ] Optional information is visibly optional.
- [ ] Loading, validation, success, empty, and error states are designed.
- [ ] Reduced-motion and keyboard accessibility are considered.

---

## 21. Final Product Principle

**Make creating a useful business page easier than creating a website.**

The user should be able to explain what they want, answer a few relevant questions, review a professional result, and publish a dynamic QR code without technical or design skills.

The question bank should be comprehensive behind the scenes, while the user-facing experience stays short, contextual, forgiving, and focused on the user's goal.
