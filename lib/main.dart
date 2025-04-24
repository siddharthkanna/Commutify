import 'package:flutter/material.dart';
import 'package:commutify/common/loading.dart';
import './providers/auth_provider.dart';
import './screens/auth/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './components/pageview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
      title: 'Commutify',
      theme: ThemeData(fontFamily: 'Outfit'),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<dynamic>(
        future: Future.value(authService.getCurrentUser()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred. Please try again.'));
          } else {
            final user = snapshot.data;
            if (user != null) {
              return const PageViewScreen();
            } else {
              return const Login();
            }
          }
        },
      ),
    );
  }
}
