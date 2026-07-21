# Simple Board

Simple Board is a local-first macOS onboarding workspace for small teams. Owners build structured onboarding programs; employees can work through their assigned journey using a private, passwordless access link.

The repository also retains the original React/Vite prototype. The native macOS product lives in [`macOS/`](macOS/).

## Demo video

[Watch the 2:49 Simple Board product demo on YouTube](https://youtu.be/rZm5OnHO75U). It follows the complete owner-to-employee onboarding loop and explains how Codex and GPT-5.6 helped turn the browser prototype into a native SwiftUI macOS app.

## What is included

- Native SwiftUI macOS 14+ owner workspace: demo setup, company profile, dashboard, programs, employees, performance, attachments, and local persistence.
- Seven editable material types: video, reading, checklist, quiz, task, document, and meeting.
- Isolated employee onboarding journeys and evidence/progress tracking.
- Passwordless employee links through Supabase RPCs. The token is held only for the active employee session.
- Demo workspaces for Sunrise Bistro (populated) and Bloom Studio (empty), plus reset and local registration flows.

## Run the macOS app

Requirements: macOS 14+ and Xcode 26+.

```sh
xcodebuild -project macOS/SimpleBoard.xcodeproj -scheme SimpleBoard -destination 'platform=macOS' build
xcodebuild -project macOS/SimpleBoard.xcodeproj -scheme SimpleBoard -destination 'platform=macOS' test
```

For local employee-link development, copy `macOS/Config/Supabase.xcconfig.example` to `macOS/Config/Supabase.xcconfig` and provide only the Supabase project URL and publishable key. That configuration is intentionally ignored by Git. Never place a service-role key, access token, signing certificate, profile, or real employee token in this repository.

See the native app's [setup and employee-link instructions](macOS/README.md) and [QA and feature guide](macOS/QA-and-Feature-Guide.md) for full workflows, test coverage, and release notes.

## Product scope

This MVP deliberately keeps owner data local on each Mac. Employee journeys are accessed through a private Supabase link; the native owner app does not yet issue remote tokens or synchronize full owner workspaces. CloudKit, browser portals, multi-admin collaboration, billing, and analytics are intentionally deferred.

## Built with Codex and GPT-5.6

Simple Board was developed as an iterative collaboration with OpenAI Codex powered by GPT-5.6. I set the product direction and evaluated each working build; Codex helped turn those decisions, screenshots, API documents, and test feedback into implementation changes that could be compiled and verified immediately.

### Where Codex accelerated the workflow

- **Architecture and implementation:** Codex translated the original React/Vite onboarding prototype into a native SwiftUI macOS application. It helped define the typed domain models, local snapshot repository, attachment handling, observable application state, and isolated employee preview/session behavior.
- **Native UX iteration:** I supplied screenshots and described layout problems observed at real window sizes. GPT-5.6 traced those problems through the SwiftUI hierarchy and helped stabilize split-view sizing, responsive editor controls, empty states, stage scrolling, keyboard behavior, and accessibility labels.
- **Swift 6 engineering:** Codex helped keep UI state on the main actor, move persistence and network work behind asynchronous boundaries, and resolve strict-concurrency and `Sendable` issues without weakening the project's compiler settings.
- **Backend integration:** After I chose Supabase for passwordless employee access, Codex interpreted the supplied API reference and Swift integration guide, then implemented the token-based employee journey using scoped RPC calls while keeping the owner workspace local-first.
- **Quality and release work:** Codex expanded Swift Testing and UI-test coverage, produced the QA and feature guide, helped create and validate the macOS icon assets, diagnosed signing and provisioning errors, built the signed archive, and prepared the TestFlight release.

### Key decisions I made

I chose the native SwiftUI direction, local-first owner storage, seven onboarding material types, passwordless employee journeys, and the overall visual and interaction design. I also decided to defer CloudKit after evaluating the provisioning and Apple Account requirements, and to ship the beta with Supabase employee links instead. I defined the MVP boundary—excluding billing, analytics, multi-admin collaboration, and public browser portals—and approved the security model, feature behavior, and release scope.

### How GPT-5.6 contributed to the final result

GPT-5.6 was especially useful as a reasoning and implementation partner across disciplines. It connected visual evidence from screenshots to layout code, converted product feedback into precise SwiftUI changes, mapped backend documentation into typed Swift networking interfaces, designed regression cases around real failure modes, and interpreted Xcode archive and distribution logs during the TestFlight process. This shortened the loop between identifying a problem, implementing a solution, and validating the result.

All credentials, signing identities, provisioning profiles, Apple and Supabase account access, product judgment, design approval, and final release decisions remained under my control. Codex accelerated the engineering workflow; I remained responsible for the product and every external action.

## Repository hygiene

The `.gitignore` excludes local dependency folders, build outputs, developer-specific Supabase configuration, and common editor/OS artifacts. Before publishing any change, review it with `git status` and verify that no real tokens or credentials are staged.
