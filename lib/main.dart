/*
 * Entry point of the Flutter app. Initializes Firebase and sets up routing and providers.
 */

import 'package:book_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'providers/review_provider.dart';
import 'providers/book_provider.dart';



import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        
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
          // TODO: register other routes
        },
      ),
    );
  }
}