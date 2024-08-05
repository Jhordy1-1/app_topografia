import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class FirebaseService {
  static Future<void> initializeFirebase() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDXChzKZ0lMgzlrJXR1eOlY7ydVECue62g",
          appId: "1:225431760087:web:70644a7377f2fa0636d492",
          messagingSenderId: "225431760087",
          projectId: "apps-1bac3",
        ),
      );
    } else if (Platform.isAndroid) {
      await Firebase.initializeApp(); // Usar la configuración predeterminada para Android
    }
  }

}
