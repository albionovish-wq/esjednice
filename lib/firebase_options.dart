import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_test_key',
    appId: '1:1234567890:web:test',
    messagingSenderId: '1234567890',
    projectId: 'esjednice-test',
    authDomain: 'esjednice-test.firebaseapp.com',
    databaseURL: 'https://esjednice-test.firebaseio.com',
    storageBucket: 'esjednice-test.appspot.com',
  );
}
