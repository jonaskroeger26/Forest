# City Focus Mobile/Web

Flutter app targeting Android and web.

## Setup

1. Install Flutter stable and run:
   - `flutter pub get`
2. Configure Firebase:
   - `flutterfire configure --project <your-project-id>`
   - Replace placeholders in `lib/core/firebase/firebase_options.dart` if not generated.
3. Start app:
   - Android: `flutter run -d android`
   - Web: `flutter run -d chrome`

## Notes

- Android blocked-app enforcement uses `PACKAGE_USAGE_STATS`.
- Method channel names:
  - `city_focus/blocked_apps`
  - `city_focus/blocked_apps_events`
