
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyD7MxFBhKi2Hw2wC570ZxsT3yp_ZBOpvBA',
    appId: '1:22940883304:web:3bda8940774208b3eededd',
    messagingSenderId: '22940883304',
    projectId: 'tugas-mcc-fb241',
    authDomain: 'tugas-mcc-fb241.firebaseapp.com',
    databaseURL: 'https://tugas-mcc-fb241-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-mcc-fb241.firebasestorage.app',
    measurementId: 'G-GF4WYTZM11',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-RvaFAjj7OAbdwFk-UgEBL_qqP6Zfewg',
    appId: '1:22940883304:android:32a0c3a7130fa97beededd',
    messagingSenderId: '22940883304',
    projectId: 'tugas-mcc-fb241',
    databaseURL: 'https://tugas-mcc-fb241-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-mcc-fb241.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvgkAEb1pX7yG6xaID5Zh9gj3TcusGdFo',
    appId: '1:22940883304:ios:9845113afca4f6b4eededd',
    messagingSenderId: '22940883304',
    projectId: 'tugas-mcc-fb241',
    databaseURL: 'https://tugas-mcc-fb241-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-mcc-fb241.firebasestorage.app',
    iosBundleId: 'com.example.tugasMcc',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvgkAEb1pX7yG6xaID5Zh9gj3TcusGdFo',
    appId: '1:22940883304:ios:9845113afca4f6b4eededd',
    messagingSenderId: '22940883304',
    projectId: 'tugas-mcc-fb241',
    databaseURL: 'https://tugas-mcc-fb241-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-mcc-fb241.firebasestorage.app',
    iosBundleId: 'com.example.tugasMcc',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7MxFBhKi2Hw2wC570ZxsT3yp_ZBOpvBA',
    appId: '1:22940883304:web:eb22fbc7478b748ceededd',
    messagingSenderId: '22940883304',
    projectId: 'tugas-mcc-fb241',
    authDomain: 'tugas-mcc-fb241.firebaseapp.com',
    databaseURL: 'https://tugas-mcc-fb241-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-mcc-fb241.firebasestorage.app',
    measurementId: 'G-4EM8PKQTNQ',
  );
}
