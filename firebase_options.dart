// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAhQpgAeLqJfkbh###n_ICfOIrV13rdEk',
    appId: '1:568690091284:web:52e9748d1640a788ed4e01',
    messagingSenderId: '568690091284',
    projectId: 'agri-visionai',
    authDomain: 'agri-visionai.firebaseapp.com',
    storageBucket: 'agri-visionai.appspot.com',
    measurementId: 'G-X38CHFR9FT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBT9WlR####sq93egHTGjP2GUxuPn1K0I',
    appId: '1:568690091284:android:2afb540f2b0edcd1ed4e01',
    messagingSenderId: '568690091284',
    projectId: 'agri-visionai',
    storageBucket: 'agri-visionai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCfU######-8rci523VAJFGy3r4aMpHGLOk',
    appId: '1:568690091284:ios:945cf72abbaee2d1ed4e01',
    messagingSenderId: '568690091284',
    projectId: 'agri-visionai',
    storageBucket: 'agri-visionai.appspot.com',
    iosBundleId: 'com.example.apk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCfUV1Tzu-8rci523VAJFGy3r4aMpHGLOk',
    appId: '1:568690091284:ios:945cf72abbaee2d1ed4e01',
    messagingSenderId: '568690091284',
    projectId: 'agri-visionai',
    storageBucket: 'agri-visionai.appspot.com',
    iosBundleId: 'com.example.apk',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhQpgAeLqJfkbhrH5Sn_ICfOIrV13rdEk',
    appId: '1:568690091284:web:f626d3fa218110fbed4e01',
    messagingSenderId: '568690091284',
    projectId: 'agri-visionai',
    authDomain: 'agri-visionai.firebaseapp.com',
    storageBucket: 'agri-visionai.appspot.com',
    measurementId: 'G-7TD5LNCG9D',
  );
}
