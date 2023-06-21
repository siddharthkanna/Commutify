import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/screens/auth/details.dart';
import '../../Themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer(
          builder: (context, WidgetRef ref, child) {
            final auth = ref.watch(authProvider);

            return Column(
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
                  width: 300, // Adjust the width as needed
                  child: ElevatedButton(
                    onPressed: () {},
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
                Center(
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      style: const TextStyle(color: Apptheme.fourthColor),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                          horizontal: 18.0,
                        ),
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Apptheme.thirdColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                              const BorderSide(color: Apptheme.fourthColor),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        // You can add more validation logic for email format, etc.
                        return null;
                      },
                      onSaved: (value) {
                        _email = value;
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
                      obscureText: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                          horizontal: 18.0,
                        ),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Apptheme.thirdColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                              const BorderSide(color: Apptheme.fourthColor),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        //  add more validation logic for password strength, etc.
                        return null;
                      },
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Add spacing of 20
                ElevatedButton(
                  onPressed: () async {
                  //  if (_formKey.currentState?.validate() ?? false) {
                  //   _formKey.currentState?.save();
                  //    final loginSuccess =
                  //        await auth.login(_email!, _password!);

                      {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DetailsPage(),
                            ),
                          );
                        });
                      }
                    //}
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
            );
          },
        ),
      ),
    );
  }
}
