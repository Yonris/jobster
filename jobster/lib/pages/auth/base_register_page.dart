import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobster/pages/auth/role_selector_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Force account picker by signing out first
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sign In')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SignInScreen(
                    providers: [EmailAuthProvider()],
                    subtitleBuilder: (context, action) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: action == AuthAction.signIn
                            ? const Text(
                                'Welcome to FlutterFire, please sign in!',
                              )
                            : const Text(
                                'Welcome to Flutterfire, please sign up!',
                              ),
                      );
                    },
                    footerBuilder: (context, action) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'By signing in, you agree to our terms and conditions.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                    sideBuilder: (context, shrinkOffset) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('flutterfire_300x.png'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12,
                  ),
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/google_logo.png', // Add your Google logo asset here
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: () async {
                      final userCredential = await signInWithGoogle();
                      if (userCredential == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google sign-in cancelled or failed'),
                          ),
                        );
                      }
                      // else Firebase auth stream will update and rebuild
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // User is signed in:
        return const RoleSelectorPage();
      },
    );
  }
}
