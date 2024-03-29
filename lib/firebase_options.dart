// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC17gn7DWszaIvssa4dy5wNMrFS7WSvSUk',
    appId: '1:956692196402:web:7d7fba226d16d2543f602b',
    messagingSenderId: '956692196402',
    projectId: 'flutternoteapp-cfd1f',
    authDomain: 'flutternoteapp-cfd1f.firebaseapp.com',
    storageBucket: 'flutternoteapp-cfd1f.appspot.com',
    measurementId: 'G-HL5E3HSJ6G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPYZeZVGq-I8yGicyKNMRZHXB08iil0uU',
    appId: '1:956692196402:android:7fef21e5525b694d3f602b',
    messagingSenderId: '956692196402',
    projectId: 'flutternoteapp-cfd1f',
    storageBucket: 'flutternoteapp-cfd1f.appspot.com',
  );
}
