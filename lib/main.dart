import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'providers/user_provider.dart';
import 'providers/book_provider.dart';
import 'providers/review_provider.dart';
import 'providers/discussion_provider.dart';
import 'providers/recommendation_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reading_list_screen.dart';
import 'screens/settings_screen.dart';

/*
 * Entry point of the Flutter app. Initializes Firebase and sets up routing and providers.
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DISABLE reCAPTCHA on Android emulators/dev builds ***
  await FirebaseAuth.instance
      .setSettings(appVerificationDisabledForTesting: true);


  runApp(const BookApp());
}

/*
 * BookApp is the root widget. 
 */
class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => DiscussionProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        
        // Provides authentication state and methods via UserProvider
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      
      child: MaterialApp(
        title: 'Book Recommendation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        
        // Defines initial route
        initialRoute: '/login',
        
        // Available routes
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/search': (_) => const SearchScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/reading-list': (_) => const ReadingListScreen(),
          '/settings': (_) => const SettingsScreen(),        },
      ),
    );
  }
}