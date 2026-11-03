// Android client configuration from google-services.json.
// These identifiers are public client configuration, not admin credentials.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Firebase is configured for Android only.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDTOP7sV-DPw-O8h9hvbMOjYYkSJkX8pyM",
    appId: "1:254661084551:android:d9682b82af279b82103f22",
    messagingSenderId: "254661084551",
    projectId: "recipebox-qe190009",
    storageBucket: "recipebox-qe190009.firebasestorage.app",
  );
}
