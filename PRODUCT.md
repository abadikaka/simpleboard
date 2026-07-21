# Simple Board — Product Context

Read this document before making product decisions. It describes the product that is currently shipped and demonstrated from this repository.

## What Simple Board is

**Simple Board** is a local-first macOS onboarding workspace for small, non-technical teams: restaurants, retail businesses, clinics, studios, and agencies. It gives an owner a clear place to build onboarding, assign people, inspect learning evidence, and spot employees who may need support.

The intended experience is deliberately straightforward:

1. An owner starts a workspace or explores a demo.
2. They create a structured onboarding program for a role.
3. They assign an employee and follow progress and evidence.
4. An employee completes a focused, private onboarding journey.

The product is for people running teams, not for people who want to configure enterprise software.

## What is implemented

The native product is the SwiftUI macOS app in `macOS/`. It supports macOS 14 and later.

- Local registration, demo selection, account switching, first-run company setup, and demo reset.
- A native owner workspace with Company Profile, Dashboard, Programs, Employees, and Performance.
- Programs with draft/published status, banner attachments, stages, deadlines, drag-and-drop stage ordering, duplication, deletion, Insights, and isolated Preview.
- Seven material types: video, reading, checklist, quiz, task, document, and meeting.
- Employee records, department filtering, assignment and reassignment confirmation, local employee sign-in, progress, quiz scores, checklist evidence, and document acknowledgements.
- A passwordless Supabase employee journey: a scoped employee access token opens only that employee's assigned journey and records material completion/evidence through documented RPCs.
- Local persistence through a versioned JSON snapshot in Application Support, with attachments stored separately and local credentials kept in Keychain.

The included demos are Sunrise Bistro, which is populated, and Bloom Studio, which intentionally begins empty.

## Product boundaries for this MVP

The owner workspace is intentionally local-first. It does **not** yet sync a full owner workspace between Macs, create remote employee records/tokens from the owner UI, or provide collaborative multi-admin editing.

The Supabase employee flow is a focused journey endpoint, not a general browser portal. A backend administrator currently creates the employee record, assigns a published program, generates a high-entropy access token, and sends the private link. The Mac app then calls the token-protected `get_employee_portal`, `record_material_detail`, and `mark_material_complete` RPCs.

The following are intentionally out of scope for this release:

- CloudKit/iCloud workspace sync and Apple Account invitations.
- Public program dashboards or public employee links.
- Browser-based owner portals, billing, analytics, and multi-admin collaboration.
- Owner-side remote invitation issuance and workspace synchronization.

## Architecture at a glance

- **Native application:** SwiftUI on macOS, with semantic system colors and native navigation, tables, menus, dialogs, file import, drag-and-drop, keyboard access, and VoiceOver labels.
- **State and storage:** a main-actor observable app store backed by an actor-based repository. Local edits are retained if disk saves fail; snapshot writes are serialized and atomic.
- **Security:** local account credentials use Keychain. The app never stores a Supabase service-role key. Employee portal tokens remain in memory for the active remote session.
- **Testing:** Swift Testing covers domain, persistence, selection repair, progress, and employee-session behavior. UI tests cover important navigation and destructive-flow smoke paths; the QA guide documents manual macOS checks that are not reliable to automate.

## Product decisions

- Keep the owner experience usable without cloud setup or a backend.
- Let employees receive a private, focused journey rather than exposing the owner workspace.
- Favor clear, native macOS workflows over reproducing the original web UI exactly.
- Defer shared-workspace synchronization until there is a validated multi-user requirement and operational plan.

## Repository map

- `macOS/` — the shipped native Simple Board application, tests, configuration example, and QA guide.
- `src/` — the retained React/Vite prototype. It is historical reference material and does not share state with the macOS app.
- `README.md` — build instructions, current scope, and an accurate record of how Codex and GPT-5.6 supported development.

For detailed setup, employee-link handling, layout acceptance, and release smoke testing, see `macOS/README.md` and `macOS/QA-and-Feature-Guide.md`.
