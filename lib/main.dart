import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './providers/auth_provider.dart';
import 'package:flutter/material.dart';
import './screens/auth/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import './components/pageview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final authProvider =
    ChangeNotifierProvider<AuthService>((ref) => AuthService());

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authProvider);

    return MaterialApp(
      title: 'RideRover',
      theme: ThemeData(fontFamily: 'Outfit'),
      home: FutureBuilder<User?>(
        future: Future.value(authService.getCurrentUser()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error occurred: ${snapshot.error}'),
              ),
            );
          } else {
            final user = snapshot.data;
            if (user != null) {
              return const PageViewScreen(); 
            } else {
              return Login();
            }
          }
        },
      ),
    );
  }
}
