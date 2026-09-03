# DayPilot

AI-powered Student Operating System that automatically plans a student's day instead of simply storing tasks.

## Features

- **AI-Powered Day Planning**: Automatically generates optimized daily schedules
- **Task Management**: Create, organize, and track tasks efficiently
- **Schedule Integration**: Seamless calendar and schedule management
- **Smart Notifications**: Intelligent reminders and updates
- **Cross-Platform**: Built with Flutter for iOS and Android

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Architecture**: Clean Architecture with feature-first structure
- **UI**: Material Design 3
- **Backend**: Supabase (placeholder)
- **Authentication**: Firebase Auth (placeholder)
- **Push Notifications**: Firebase Cloud Messaging (placeholder)

## Project Structure

```
lib/
├── core/                    # Core functionality and utilities
│   ├── config/             # App configuration (providers, router, Firebase, Supabase)
│   ├── constants/          # App-wide constants
│   ├── error/              # Error handling (exceptions, failures)
│   ├── theme/              # App themes (light/dark)
│   ├── utils/              # Utility functions and helpers
│   └── network/            # Network layer (Dio client)
├── features/               # Feature modules (Clean Architecture)
│   ├── auth/              # Authentication feature
│   ├── dashboard/         # Dashboard feature
│   ├── schedule/          # Schedule feature
│   └── tasks/             # Tasks feature
├── shared/                # Shared widgets and providers
│   ├── widgets/           # Reusable widgets
│   └── providers/         # Shared providers
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
2. Navigate to the mobile directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run code generation (for Riverpod annotations):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Configuration

### Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories
5. Uncomment and configure Firebase initialization in `lib/core/config/firebase_config.dart`

### Supabase

1. Create a Supabase project at [Supabase Dashboard](https://supabase.com/dashboard)
2. Get your project URL and anon key
3. Update constants in `lib/core/constants/app_constants.dart`
4. Uncomment and configure Supabase initialization in `lib/core/config/supabase_config.dart`

## Development

### Code Generation

This project uses code generation for:
- Riverpod providers
- Freezed models
- JSON serialization

Run the following command after making changes to annotated files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

The project uses `flutter_lints` for code quality. Run:
```bash
flutter analyze
```

## Architecture

This project follows Clean Architecture principles:

- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Data sources, models, repository implementations
- **Presentation Layer**: UI, widgets, state management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Status

This is the initial project structure setup. Business logic implementation is pending.
