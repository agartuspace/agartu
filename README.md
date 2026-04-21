# Platform Agartu Space

A Flutter social hub application built for the Agartu Space educational platform.

---

## Firebase Setup (Required before running)

1. Go to https://console.firebase.google.com and create a new project.

2. Enable **Authentication** → Sign-in method → **Email/Password**.

3. Enable **Cloud Firestore** → Start in test mode.

4. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

5. In the project root, run:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project. This generates `lib/firebase_options.dart` — **replace the placeholder file** with the generated one.

6. For Android: the `google-services.json` file is downloaded and placed at `android/app/google-services.json`.

7. In `android/build.gradle`, add inside `buildscript > dependencies`:
   ```groovy
   classpath 'com.google.gms:google-services:4.4.0'
   ```

8. In `android/app/build.gradle`, add at the bottom:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```

---

## Firestore Security Rules

In the Firebase Console → Firestore → Rules, set:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## Running the App

```bash
flutter pub get
flutter run
```

---

## Localization Key Generation (optional)

To regenerate locale keys from translation JSON files:

```bash
flutter pub run easy_localization:generate -S "assets/translations" -O "lib/constants" -o "locale_keys.dart" -f keys
```

---

## Features

- Firebase Authentication (email + password)
- Cloud Firestore posts feed (real-time stream)
- BLoC/Cubit state management (AuthCubit, PostCubit, ApiCubit)
- Dio HTTP client for external quotes API
- SharedPreferences for theme, language, username
- easy_localization (English, Russian, Kazakh)
- Light/Dark theme
- Post like animation + feed entry animation
- 4-tab navigation: Feed, Create, Explore, Profile
