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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyBpkT2Ymw4fwRz5RraCLeSyu5IXCrgKnb4',
    appId: '1:1039881544081:web:cbaf585fc05163d0ef7a30',
    messagingSenderId: '1039881544081',
    projectId: 'node-practice-f048c',
    authDomain: 'node-practice-f048c.firebaseapp.com',
    storageBucket: 'node-practice-f048c.appspot.com',
    measurementId: 'G-TDDFY9Y6N8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkScxiEQV1Tlr2OsBwQBCfpPTrtinJhZ4',
    appId: '1:1039881544081:android:c7ff68ecc237ee57ef7a30',
    messagingSenderId: '1039881544081',
    projectId: 'node-practice-f048c',
    storageBucket: 'node-practice-f048c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4pMFoNwSZDV-8KCJN5WwUZqc9PKu8vno',
    appId: '1:1039881544081:ios:3bc9499cacac8817ef7a30',
    messagingSenderId: '1039881544081',
    projectId: 'node-practice-f048c',
    storageBucket: 'node-practice-f048c.appspot.com',
    androidClientId: '1039881544081-jduacu25o1dlhe2kpn8ogjim7ip93h4a.apps.googleusercontent.com',
    iosClientId: '1039881544081-jbn2el1lf8bnn59kcjsc7vl36nti2o2u.apps.googleusercontent.com',
    iosBundleId: 'com.example.mlritpool',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4pMFoNwSZDV-8KCJN5WwUZqc9PKu8vno',
    appId: '1:1039881544081:ios:d0cb000b601f46cfef7a30',
    messagingSenderId: '1039881544081',
    projectId: 'node-practice-f048c',
    storageBucket: 'node-practice-f048c.appspot.com',
    androidClientId: '1039881544081-jduacu25o1dlhe2kpn8ogjim7ip93h4a.apps.googleusercontent.com',
    iosClientId: '1039881544081-vgjlphjriv5ir397ftbpi9ka1e8a7omu.apps.googleusercontent.com',
    iosBundleId: 'com.example.mlritpool.RunnerTests',
  );
}
