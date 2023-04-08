import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static Future<bool> isAuthenticated() async {
    // Get the current user from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is authenticated
    if (user != null) {
      // User is authenticated, allow access
      return true;
    } else {
      // User is not authenticated, deny access
      return false;
    }
  }
}
