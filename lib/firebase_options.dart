import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// NOTE: These are dummy keys to prevent the app from crashing on startup
/// before `flutterfire configure` is run. To make authentication and 
/// database work, you MUST run `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALV9SPvrnBgtIDEazCmjzHh9zwzBVMwQo',
    appId: '1:939157132941:web:68a25ab66c843979f534c4',
    messagingSenderId: '939157132941',
    projectId: 'certifications-f0481',
    authDomain: 'certifications-f0481.firebaseapp.com',
    storageBucket: 'certifications-f0481.firebasestorage.app',
    measurementId: 'G-63SG6EP0L2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRvgfUWnIL8yJVG0gyNGIal3YSjXdXbss',
    appId: '1:939157132941:android:4184e26d58b1ec7cf534c4',
    messagingSenderId: '939157132941',
    projectId: 'certifications-f0481',
    storageBucket: 'certifications-f0481.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtWjz_WOKZ4td2ehu8QtnPhiaMmqDHPgY',
    appId: '1:939157132941:ios:db95ba85c04202d4f534c4',
    messagingSenderId: '939157132941',
    projectId: 'certifications-f0481',
    storageBucket: 'certifications-f0481.firebasestorage.app',
    iosBundleId: 'com.example.agartu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtWjz_WOKZ4td2ehu8QtnPhiaMmqDHPgY',
    appId: '1:939157132941:ios:db95ba85c04202d4f534c4',
    messagingSenderId: '939157132941',
    projectId: 'certifications-f0481',
    storageBucket: 'certifications-f0481.firebasestorage.app',
    iosBundleId: 'com.example.agartu',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyALV9SPvrnBgtIDEazCmjzHh9zwzBVMwQo',
    appId: '1:939157132941:web:ee20db60fc25f89af534c4',
    messagingSenderId: '939157132941',
    projectId: 'certifications-f0481',
    authDomain: 'certifications-f0481.firebaseapp.com',
    storageBucket: 'certifications-f0481.firebasestorage.app',
    measurementId: 'G-MPXGDNEHXB',
  );

}