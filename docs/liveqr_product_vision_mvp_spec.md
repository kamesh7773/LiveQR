# Live QR — Product Vision and MVP Specification

## 1. Product Overview

**Live QR** is an AI-powered platform that helps people create a professional online page for their business or use case—even if they do not already have a website.

Instead of requiring users to paste an existing URL into a QR generator, Live QR lets them describe what they do, provide relevant details, generate a polished page, and publish it behind a QR code.

**Core idea:** The business page is the product; the QR code is the distribution mechanism.

### Problem

Many traditional QR generators start with a destination URL or a predefined QR data type. A small business owner who has no website must first create or buy a website before their QR code can direct customers to a useful online experience.

### Solution

Live QR combines conversational onboarding, AI-generated pages, a visual editor, publishing, and dynamic QR codes in one workflow.

### Target users

- Small and local businesses
- Restaurants, cafés, bakeries, and food vendors
- Retail shops and boutiques
- Freelancers and professionals
- Event organizers
- Businesses that need a simple digital presence without building a full website

## 2. Product Differentiation

| Capability | Traditional QR generator | Live QR |
|---|---|---|
| Start with an existing URL | Common workflow | Optional |
| Start with a plain-language description | Usually not the primary workflow | Core workflow |
| Generate a business page from details | Not usually the primary workflow | Core feature |
| Edit page content using AI instructions | Varies by product | Core feature |
| Generate a QR code | Yes | Yes |
| Update published content without reprinting the QR | Supported by dynamic QR products | Core feature |
| Select page sections and design based on the use case | Varies | AI-assisted |
| Create a basic online presence without website-building skills | Not usually the main focus | Core value proposition |

Live QR should not compete only on QR generation. Its main differentiation is helping users create and maintain the destination experience behind the QR code.

## 3. Primary User Journey

### Step 1 — Describe what you want

The user opens Live QR and describes their business or intended use.

Example:

> I run a men's clothing store in Jodhpur. We sell shirts, jeans, and formal wear. Customers should be able to call us, view our products, and find our store.

Users can also start from a suggested use case, such as:
- Business page
- Restaurant menu
- Digital business card
- Event or invitation

### Step 2 — Collect relevant details

The system extracts details already provided and asks only for essential missing information.

Potential fields include:
- Business or display name
- Business category
- Phone number
- Email address
- Physical address or map location
- Opening hours
- Short description
- Logo and photos
- Menu, services, or products, where relevant
- Social media links
- Preferred language and visual style

Fields should depend on the page type. For example, a digital business card should not require a physical address, and a restaurant page should not require a company registration number.

### Step 3 — Generate the page

The AI creates a mobile-friendly page using an approved component library and a validated page specification. It selects relevant sections, organizes the supplied information, and applies a suitable visual style.

Possible sections:
- Hero or introduction
- About the business
- Products, services, or menu
- Contact actions
- Address and map link
- Opening hours
- Gallery
- Social links
- Offers or announcements
- Booking, enquiry, or RSVP action when applicable

The system must not invent factual business information. Missing details should remain absent or be requested from the user.

### Step 4 — Preview and edit

The owner previews the page before publishing. They can edit fields directly or request changes conversationally.

Examples:
- “Add our Diwali offer.”
- “Change our phone number.”
- “Make the page look more premium.”
- “Add these three products.”
- “Update our opening hours.”

A small requested change should modify only the relevant part of the page, rather than unnecessarily rewriting the entire design or content.

### Step 5 — Publish and create the QR code

After approval, Live QR publishes the page and creates a QR code that points to a stable Live QR URL.

The owner can:
- Download the QR code
- Share it digitally
- Print it on packaging, menus, business cards, posters, or signage
- Copy the public page link

### Step 6 — Update after publishing

The owner can change page content later without changing the QR code. The public URL stays stable while the currently published page version changes.

## 4. Suggested First Page Types

Keep the MVP focused on three page types.

### 4.1 Business Profile
- Business name and description
- Logo or cover image
- Phone and email actions
- Address and map link
- Opening hours
- Services or product highlights
- Social links

### 4.2 Restaurant Menu
- Restaurant name and introduction
- Menu categories and items
- Prices supplied by the owner
- Food images
- Address and opening hours
- Call, enquiry, or ordering action where supported

### 4.3 Digital Business Card
- Name and role
- Company or business name
- Profile photo or logo
- Phone, email, and website
- Social links
- Save-contact action, if supported

Other page types—such as events, invitations, product information, company profiles, and advanced catalogs—can follow after the core workflow is reliable.

## 5. Technical Architecture

### Client application
**Flutter**
- Business onboarding
- Dashboard and page management
- AI chat editor
- Form-based editing
- Page preview
- QR creation, download, and sharing
- Scan analytics
- Account and workspace settings

### Backend
**Node.js**
- REST API
- Authentication and authorization
- Business and page data management
- AI orchestration
- Page-specification validation
- Versioning and publishing
- QR destination management
- Asset upload coordination
- Analytics collection and reporting
- Background job processing where needed

### Data and infrastructure
- **PostgreSQL:** users, workspaces, businesses, pages, versions, QR records, and analytics data
- **Object storage:** logos, images, and other uploaded assets
- **AI provider:** converts user descriptions and edit instructions into structured page specifications
- **Optional Redis and job queue:** background AI generation, retries, and other asynchronous tasks
- **Public web renderer:** serves the published page to visitors in a normal mobile or desktop browser
- **CDN/cache layer:** improves delivery speed when required

### Critical architectural rule

Flutter is the owner/editor application; it must not be required for visitors to open a published page.

When a customer scans a QR code, the destination should load in a regular browser without requiring an app installation or login.

## 6. AI Generation and Page Rendering

The AI should return a **structured, validated page specification**, not arbitrary HTML, JavaScript, or Flutter source code.

A page specification can define:
- Page type
- Theme and design tokens
- Section order
- Component types
- Text and business data
- Image references
- Action buttons
- Layout options supported by the renderer

The backend validates the result against a schema and allowed component definitions before saving it. Both the Flutter preview and public web renderer should use the same conceptual schema and design tokens. Their rendering implementations may differ, so visual parity must be tested rather than assumed.

### AI safety and quality rules
- Do not invent phone numbers, addresses, prices, opening hours, reviews, or business claims.
- Keep user-provided factual content distinct from AI-generated marketing copy.
- Validate URLs and uploaded assets.
- Allow only supported components and properties.
- Reject or safely handle malformed model output.
- Preserve the current published version if generation or validation fails.
- Apply localized edits where possible.
- Ask the user to confirm important changes before publishing.
- Treat user content and uploaded files as untrusted input.

## 7. Dynamic QR and Publishing Model

The QR code should point to a stable Live QR URL, for example:

`https://liveqr.example/p/{public_slug}`

The example domain is illustrative and must be replaced with the production domain.

The stable URL resolves to the page's currently published version. Editing a draft must not change the public page until the owner publishes it.

Recommended behavior:
1. Create or update a draft.
2. Validate the draft.
3. Preview the draft.
4. Publish it as a new immutable version.
5. Atomically update the page's published-version pointer.
6. Invalidate relevant caches.
7. Keep previous versions available for rollback.

A failed AI generation, validation, or publish operation must not break the current public page.

## 8. Suggested Core Data Model

These are initial entities; final table structure should be adjusted during implementation.

- `users`
- `workspaces`
- `workspace_members`
- `businesses`
- `pages`
- `page_versions`
- `qr_codes`
- `assets`
- `ai_jobs`
- `analytics_events`
- `analytics_daily`
- `subscriptions` (when billing is introduced)
- `audit_logs` (where needed for security and traceability)

Potential relationships:
- A user can belong to one or more workspaces.
- A workspace can manage multiple businesses and pages.
- A page can have multiple immutable versions.
- A page can have one current published version.
- A QR code points to a stable public destination or page identifier.
- Assets can be reused by authorized pages in the same workspace.

## 9. Initial API Areas

Exact routes and payloads should be finalized after reviewing the existing Node.js backend.

### Authentication and account
- Register, log in, log out, refresh session
- Current-user profile
- Workspace membership and permissions

### Businesses and pages
- Create and update business details
- Create a page draft
- Fetch page and draft
- Update page fields or sections
- List pages and QR codes

### AI
- Generate a page from a description
- Ask for missing information or return structured questions
- Edit a page using an instruction
- Check generation status if jobs are asynchronous

### Versions and publishing
- Validate a draft
- Preview a draft
- Publish a page
- List page versions
- Restore a previous version

### QR codes
- Create QR code
- Configure supported QR appearance options
- Download or share QR image
- Fetch QR destination and settings

### Assets
- Request an upload URL or upload through the API
- Validate file type and size
- Associate assets with a page

### Analytics
- Record page views and QR visits
- Report scans, unique visitors, device categories, and referrers where available
- Filter analytics by page and date range

## 10. Analytics

Start with simple, useful metrics:
- Total page visits
- Approximate unique visitors
- Visits over time
- Device category
- Referrer where available
- Top-performing pages and QR codes

Define analytics carefully:
- A QR scan cannot always be distinguished perfectly from a direct link visit.
- Avoid claiming that every request represents a unique human.
- Deduplicate events where practical.
- Filter known bots and preview traffic where possible.
- Respect privacy requirements and minimize collected data.

## 11. UX and Product Quality Requirements

- Mobile-first public pages that load quickly.
- Clear draft versus published states.
- A persistent, easy-to-find preview/publish action in the editor.
- Conversational editing plus direct field editing.
- Relevant defaults rather than an overwhelming settings form.
- Useful empty states and generation progress feedback.
- Clear recovery when AI generation fails.
- Accessible typography, contrast, tap targets, and reduced-motion support.
- Preview the page at common mobile widths.
- Provide a rollback option for published changes.
- Avoid adding visual complexity that does not help the user complete their task.

## 12. Security, Reliability, and Cost Controls

- Enforce authorization on every workspace, page, asset, and analytics endpoint.
- Validate and sanitize all user input.
- Restrict uploaded file types, size, and processing.
- Protect public forms from spam and abuse.
- Rate-limit authentication, AI generation, and public endpoints where appropriate.
- Keep API keys and model credentials on the server.
- Track AI usage and apply quotas or plan limits.
- Use background jobs and bounded retries for long-running generation.
- Log errors without exposing secrets or sensitive customer data.
- Keep the last valid published version available during failures.
- Add safeguards against phishing, deceptive pages, and abusive content.

## 13. MVP Roadmap

### Phase 1 — Core creation and publishing
- Authentication
- Business description and onboarding
- Business Profile, Restaurant Menu, and Digital Business Card
- Structured AI page generation
- Page preview
- Stable public URLs
- QR generation and download
- Public browser rendering

### Phase 2 — Editing and reliability
- AI chat editing
- Direct field and section editing
- Draft and published versions
- Publish validation
- Version history and rollback
- Asset library and image handling
- Basic analytics
- Error recovery and usage limits

### Phase 3 — Growth features
- More page types
- Advanced QR styling and print-ready downloads
- Custom branding and domains
- Enquiry or RSVP forms
- Team collaboration
- Subscription and billing
- More detailed analytics

Prioritize based on actual user feedback and usage rather than implementing every possible feature up front.

## 14. MVP Acceptance Checklist

- [ ] A user can create a page without having an existing website URL.
- [ ] The user can describe a business in plain language.
- [ ] The app asks only for relevant missing information.
- [ ] AI generates a valid page using supported components.
- [ ] Unsupported or invented business facts are not silently published.
- [ ] The user can preview and edit the draft.
- [ ] A QR code is created for a stable public URL.
- [ ] The public page opens in a browser without the Live QR app.
- [ ] Updating and publishing the page does not require reprinting the QR code.
- [ ] Failed generation or publishing leaves the previous published page intact.
- [ ] Authorized users can manage only the pages and assets they have permission to access.
- [ ] The page works on common mobile screen sizes.
- [ ] Basic analytics distinguish page visits from any stronger claims that the available data cannot support.

## 15. Product Principle

**Make creating a useful business page easier than creating a website.**

Users should be able to explain what they do, confirm their information, review a professional result, and publish a QR code without needing technical or design skills. Keep the experience focused, make AI output predictable through structured data and validation, and make published pages reliable for every visitor who scans the code.
