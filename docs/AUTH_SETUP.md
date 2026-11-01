# Sign-in and verification setup

The app supports Firebase phone OTP on Android/iOS/web and Google sign-in on Android/iOS/macOS/web. Offline guides and visit preparation do not require an account. A phone or Google account proves account access; it does **not** prove farmer registration, land ownership, procurement eligibility, or government approval.

## What the code does

- Restores the Firebase session using cached ID-token claims when available, with a bounded wait and immediate offline access.
- Uses native phone verification on Android/iOS and `signInWithPhoneNumber` plus reCAPTCHA on web.
- Handles Hindi digits and pasted +91 numbers, SMS-code autofill, 60-second resend cooldown, slow connections, expired codes and provider failures.
- Uses the official `google_sign_in` plugin on mobile/Apple platforms and Firebase Google pop-up on web. No contacts or Drive scopes are requested.
- Routes accounts from their trusted `role` custom claim. Missing role means farmer; only exact `staff`, `driver`, or `admin` claims open those portals. Unknown claims deny access. Users cannot select a privileged role.
- Separates account sign-in from government verification in the interface. The existing centre workflows remain a practice environment until a real authorised backend is connected.

## Required Firebase console configuration

1. Enable Google and Phone providers for project `krishi-queue-5d66f`. Check current SMS quotas, billing and allowed SMS regions before enabling public phone sign-in. Do not rely on the UI cooldown for abuse protection.
2. Add the actual deployed web hostname to Firebase Authentication authorised domains. Add localhost only if needed for local development. Test web reCAPTCHA and Google pop-ups on that hostname.
3. Register Android debug and release signing SHA-1/SHA-256 certificates for package `com.justy.krishiqueue`, then download a fresh `android/app/google-services.json` with the OAuth clients. The checked-in file currently has no OAuth-client entries. An optional public web client ID can be supplied as `GOOGLE_SERVER_CLIENT_ID`; a client secret must never be embedded in the app.
4. For iOS/macOS, download the correct `GoogleService-Info.plist`, add it to the runner target, and configure the reversed-client-ID URL scheme according to the official plugin instructions. These files/URL schemes are not present in the inspected project. If needed, supply the public `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID` build values. APNs and the phone-auth background/notification setup must be checked on a real iPhone.
5. Assign staff/driver/admin custom claims only with Firebase Admin SDK in a trusted operator environment. The future backend must enforce these claims again on every protected operation; hiding a screen is not an authorisation boundary.

Do not infer that a provider is enabled merely because `firebase_options.dart` exists. No cloud settings or production users were changed by this implementation.

## Government connection

Use the official registration and procurement workflow until a written integration agreement and authenticated API are available. Never turn a farmer-entered registration number or a successful OTP into a government-verified badge. Verification must identify the issuing authority, checked record, timestamp and expiry. Collect only necessary data and do not store Aadhaar scans or bank credentials in device preferences.

## Before release

Test a real Android build with both debug and release signatures, Google cancellation, OTP expiry/resend, denied reCAPTCHA, network loss during sign-in, app restart, sign-out on a shared phone, and a revoked/invalid staff role. Use Firebase test numbers for repeat testing instead of paid SMS. Automated tests cover input validation, role parsing and the offline sign-in interface; they do not prove live OTP delivery or Google configuration.

Official implementation references (checked 31 October 2026): [Firebase Flutter phone auth](https://firebase.google.com/docs/auth/flutter/phone-auth), [Firebase Google sign-in](https://firebase.google.com/docs/auth/flutter/federated-auth), [official Google Sign-In plugin](https://pub.dev/packages/google_sign_in), [Android setup](https://pub.dev/packages/google_sign_in_android), [iOS/macOS setup](https://pub.dev/packages/google_sign_in_ios), [Firebase custom claims](https://firebase.google.com/docs/auth/admin/custom-claims).
