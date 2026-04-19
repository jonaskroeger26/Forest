# City Focus Beta Checklist

## Product

- [ ] Onboarding explains strict auto-fail behavior clearly.
- [ ] Session start is one tap from home.
- [ ] `Focusing`, `Failed`, and `Victory` states are obvious.
- [ ] City progression gives visible rewards in first day of use.

## Android Enforcement

- [ ] Usage access permission request flow tested on Samsung, Pixel, OnePlus.
- [ ] Opening blocked app while session active causes immediate fail.
- [ ] Empty blocked-app list prompts warning before starting a session.
- [ ] Foreground app polling does not drain battery excessively.

## Web

- [ ] Session timer and city loop work without Android monitor.
- [ ] UI responsiveness verified on mobile and desktop browser sizes.

## Firebase

- [ ] Firestore writes for sessions succeed for authenticated users.
- [ ] Cloud Function reward endpoint prevents duplicate rewards.
- [ ] Analytics events are visible in Firebase DebugView.
- [ ] Crashlytics receives non-fatal and fatal errors in release profile.
