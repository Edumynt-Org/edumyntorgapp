# AGENTS.md — edumyntorgapp (Flutter)

> Auto-read by AI agents. Last updated: 2026-08-12

## What This Repo Is

Flutter native mobile app for **Edumynt Library** — a free open library platform for reading books and listening to audiobooks. Talks to the PayloadCMS backend via REST API.

## Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter 3.44.9 |
| Language | Dart 3.12.2 |
| State management | Provider (to be set up) |
| HTTP | `http` package (to be added) |
| Auth storage | `flutter_secure_storage` (to be added) |
| Audio | `just_audio` + `audio_session` (to be added) |
| Design system | Material 3 + custom theme tokens |
| Testing | `flutter_test` + `mocktail` |
| Linting | `flutter_lints` |

## Current State

**Phase 1 — Auth** (not yet started in this repo)
- This is a fresh Flutter scaffold — only `lib/main.dart` exists
- No packages beyond defaults have been added yet
- Architecture and folder structure to be set up in Phase 1

## Planned Architecture

```
lib/
├── main.dart
├── core/
│   ├── theme/                  # M3 ThemeData, ColorScheme, TextTheme, tokens
│   ├── constants/              # API URLs, app constants
│   └── utils/                  # Shared utilities
├── data/
│   ├── providers/              # PayloadBackendProvider (implements repositories)
│   └── models/                 # Data models (User, Book, Chapter, etc.)
├── domain/
│   ├── models/                 # Domain entities
│   └── repositories/           # IAuthRepository, ILibraryRepository, etc.
├── presentation/
│   ├── screens/                # Screen widgets organized by feature
│   ├── widgets/                # Reusable UI components
│   └── providers/              # State management (ChangeNotifiers)
└── routes/                     # Navigation / routing
```

## Backend API

The PayloadCMS backend runs at `localhost:3000` (dev) and exposes:

```
POST   /api/users                # Registration
POST   /api/users/login          # Login (returns JWT)
POST   /api/users/logout         # Logout
POST   /api/users/refresh-token  # Refresh JWT
GET    /api/users/me             # Current user
GET    /api/books                # List books (public)
GET    /api/books/:id            # Book detail (public)
GET    /api/editions/:id         # Edition detail (public)
GET    /api/chapters/:id         # Chapter with content (public)
# ... all collections have REST endpoints
```

Auth: JWT tokens from Payload. Store in `flutter_secure_storage`. Send as `Authorization: JWT <token>` header.

## Design System

- **Primary font**: Plus Jakarta Sans
- **UI style**: Duolingo-inspired — friendly, gamified, high-contrast, rounded corners, bold typography
- **Theme**: Light + Dark modes
- **Implementation**: Material 3 `ThemeData` with fully custom `ColorScheme` and `TextTheme`
- **Rule**: All tokens in `lib/core/theme/` — NO hardcoded colors or sizes in widget code

## Conventions

- **Repository pattern**: UI never calls HTTP directly — always through `IRepository` interfaces
- `PayloadBackendProvider` implements all repository interfaces
- Auth tokens in `flutter_secure_storage`, never in shared prefs
- Contributor roles (author, translator, narrator) are separate from app roles (reader, editor, admin)
- All text content from backend is Lexical JSON — needs a custom renderer widget

## Verified Commands

```bash
flutter run                 # Run on connected device
flutter test                # Run tests
flutter analyze             # Lint check
flutter build apk           # Android release build
flutter build ios           # iOS release build
```

## Related

- Backend repo: `../edumyntorg/` (PayloadCMS + Next.js)
- Full schema: `../docs/schema.md`
- Project context: `../docs/project-context.md`
