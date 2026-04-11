import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform - '
      'you can reconfigure this by running the FlutterFire CLI on each supported platform: https://firebase.flutter.dev/docs/cli#configure-ios-and-mac',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: 'demo-app-id',
    messagingSenderId: 'demo-sender-id',
    projectId: 'demo-project-id',
    authDomain: 'demo.firebaseapp.com',
    storageBucket: 'demo.appspot.com',
  );
}
