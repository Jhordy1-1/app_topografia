import 'package:flutter/material.dart';
import 'views/auth_view.dart';
import 'views/home_view.dart';
import 'services/firebase_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthView(),
        '/home': (context) => HomeView(),
        // Remove room route as it needs dynamic parameter
      },
    );
  }
}
