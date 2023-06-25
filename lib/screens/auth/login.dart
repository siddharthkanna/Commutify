import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/common/error.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/screens/auth/details.dart';
import '../../Themes/app_theme.dart';
import '../../providers/auth_provider.dart';

final emailController = TextEditingController();
final passwordController = TextEditingController();

class Login extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final error = auth.error;

    return Scaffold(
      backgroundColor: Apptheme.primaryColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MLRITPOOL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 36.0,
                    color: Apptheme.fourthColor,
                  ),
                ),
                const SizedBox(height: 50.0),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      await auth.signInWithGoogle();
                      final user = auth.getCurrentUser();
                      if (user != null) {
                        // User signed in successfully, handle the next steps
                        // save user data, navigate to next screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DetailsPage(),
                          ),
                        );
                      } else {
                        // Error occurred during sign-in
                        // Handle the error or show a message to the user
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                      ),
                      minimumSize: const Size.fromHeight(
                          50), // Adjust the height as needed
                      backgroundColor: Apptheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Apptheme.fourthColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/GoogleLogo.png',
                          width: 24.0, // Adjust the width as needed
                          height: 24.0, // Adjust the height as needed
                        ),
                        const SizedBox(
                            width:
                                10.0), // Add spacing between the image and text
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(fontFamily: 'Outfit'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
                const Text(
                  "OR",
                  style: TextStyle(
                    color: Apptheme.fourthColor,
                  ),
                ),
                const SizedBox(height: 50.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            style: const TextStyle(color: Apptheme.fourthColor),
                            controller: emailController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                                horizontal: 18.0,
                              ),
                              labelText: 'Email',
                              labelStyle:
                                  const TextStyle(color: Apptheme.thirdColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide: const BorderSide(
                                    color: Apptheme.fourthColor),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              // You can add more validation logic for email format, etc.
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            style: const TextStyle(color: Apptheme.fourthColor),
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                                horizontal: 18.0,
                              ),
                              labelText: 'Password',
                              labelStyle:
                                  const TextStyle(color: Apptheme.thirdColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide: const BorderSide(
                                    color: Apptheme.fourthColor),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              //  add more validation logic for password strength, etc.
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            await auth.signInWithEmailAndPassword(
                                email, password);

                            // Retrieve the error message
                            if (error.isNotEmpty) {
                              ErrorDialog.showErrorDialog(context, error);
                              // Error occurred during sign-in
                              // Handle the error or show a message to the user
                            } else {
                              // User signed in successfully, handle the next steps
                              // save user data, navigate to next screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DetailsPage(),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.white),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
          if (loading) const Loader(),
        ],
      ),
    );
  }
}
