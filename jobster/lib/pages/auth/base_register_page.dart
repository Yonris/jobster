import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobster/pages/auth/role_selector_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ensure account picker shows
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const RoleSelectorPage();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: Column(
            children: [
              Expanded(
                child: SignInScreen(
                  providers: [EmailAuthProvider()],
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, _) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectorPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Or register with",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    SignInButton(
                      Buttons.google,
                      text: "Continue with Google",
                      onPressed: () async {
                        final userCredential = await signInWithGoogle();
                        if (userCredential == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Google sign-in cancelled or failed',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
