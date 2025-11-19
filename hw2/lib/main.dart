import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..initializeUser(),
      child: MaterialApp(
        title: 'Message Board App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // Use Consumer directly - it will rebuild when UserProvider notifies
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Also check Firebase Auth directly
        final currentAuthUser = FirebaseAuth.instance.currentUser;
        final providerUser = userProvider.user;
        final isLoading = userProvider.isLoading;
        
        debugPrint('=== AuthWrapper rebuild ===');
        debugPrint('FirebaseAuth.instance.currentUser: ${currentAuthUser?.email ?? "null"}');
        debugPrint('Provider user: ${providerUser?.email ?? "null"}');
        debugPrint('isLoading: $isLoading');
        
        // If Firebase Auth has a user but provider is still loading, show splash
        if (currentAuthUser != null && isLoading) {
          debugPrint('Showing SplashScreen - Auth has user but provider is loading');
          return const SplashScreen();
        }

        // If Firebase Auth has a user and provider has user data, show home
        if (currentAuthUser != null && providerUser != null) {
          debugPrint('Showing HomeScreen - Both Auth and Provider have user');
          return const HomeScreen();
        }

        // If Firebase Auth has a user but provider doesn't have user data yet, show splash
        if (currentAuthUser != null && providerUser == null && !isLoading) {
          debugPrint('Auth has user but Provider doesn\'t - triggering initialization');
          // Trigger initialization if not already done
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = context.read<UserProvider>();
            if (provider.user == null && FirebaseAuth.instance.currentUser != null) {
              debugPrint('Calling initializeUser from AuthWrapper');
              provider.initializeUser();
            }
          });
          return const SplashScreen();
        }

        // No authenticated user, show login
        debugPrint('Showing LoginScreen - No authenticated user');
        return const LoginScreen();
      },
    );
  }
}
