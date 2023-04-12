import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
import 'screens/Home/add_note.dart';
import 'screens/Home/home_screen.dart';
import 'screens/Home/search_note.dart';
import 'screens/Home/settings_screen.dart';
import 'screens/Home/trash_screen.dart';
import 'screens/Login/login_screen.dart';
import 'screens/Signup/signup_screen.dart';
import 'utils/auth.dart';
import 'utils/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Note',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyAuth(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      onGenerateRoute: (settings) {
        // Check if the user is authenticated before allowing access to certain routes.
        if (settings.name == '/home' ||
            settings.name == '/add-note' ||
            settings.name == '/search-note' ||
            settings.name == '/trash' ||
            settings.name == '/settings') {
          return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                return FutureBuilder<bool>(
                  future: AuthGuard.isAuthenticated(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      // User is authenticated, allow access to the route.
                      switch (settings.name) {
                        case '/home':
                          return const HomeScreen();
                        case '/add-note':
                          return const AddNoteScreen();
                        case '/search-note':
                          return const SearchScreen();
                        case '/trash':
                          return const TrashScreen();
                        case '/settings':
                          return const SettingsScreen();
                        default:
                          return Container(); // Replace this with an error message or a 404 page if desired.
                      }
                    } else {
                      // User is not authenticated, redirect to the login screen.
                      return const LoginScreen();
                    }
                  },
                );
              });
        }
        // If the requested route is not in the list of routes that require authentication,
        // just return null to use the default route handling.
        return null;
      },
    );
  }
}
