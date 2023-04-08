import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';

import 'components/constants.dart';
import 'firebase_options.dart';
import 'screens/Home/add_note.dart';
import 'screens/Home/home_screen.dart';
import 'screens/Home/search_note.dart';
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
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
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
            settings.name == '/trash') {
          return MaterialPageRoute(builder: (context) {
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
