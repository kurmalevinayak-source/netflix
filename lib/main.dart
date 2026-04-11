import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  // Initialize Firebase (Requires user to add google-services.json/GoogleService-Info.plist or run flutterfire configure)
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      await Firebase.initializeApp();
    }
    firebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization failed: $e. Running in Demo Mode.");
  }
  
  runApp(MyApp(isFirebaseReady: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseReady;
  const MyApp({super.key, required this.isFirebaseReady});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // If Firebase isn't ready, we stay on LoginScreen for demo purposes or show Home if user wants to see UI.
          // For this clone, we'll allow entering Home even if not 'really' authenticated if Firebase failed.
          return MaterialApp(
            title: 'Netflix Clone',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            // Show HomeScreen if authenticated, otherwise show LoginScreen
            home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
