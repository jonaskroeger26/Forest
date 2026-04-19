# Analytics Events (MVP)

## Event Catalog

- `session_start`
  - `duration_minutes` (int)
- `session_result`
  - `outcome` (`success`, `failedBlockedApp`, `cancelled`)
  - `focus_seconds` (int)
- `reward_granted`
  - `coins` (int)
  - `materials` (int)

## Crash Reporting

- `FlutterError.onError` is forwarded to Firebase Crashlytics in release mode.
- In debug mode, errors are printed to console only.
