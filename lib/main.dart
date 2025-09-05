import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ross_ai_1/auth/provider/auth_provider.dart';
import 'package:ross_ai_1/firebase_options.dart';
import 'package:ross_ai_1/jurisdiction_checker/jurisdiction_checker.dart';
import 'package:ross_ai_1/landing/landing_page.dart';
import 'package:ross_ai_1/timeline_extractor/provider/timeline_extractor_provider.dart';
import './home/home_page.dart';
import "package:ross_ai_1/profile/profile_page.dart";
import 'package:ross_ai_1/profile/components/feedback_page.dart';
import 'package:ross_ai_1/profile/components/preference_page.dart';
import '../precedent_finder/precedent_finder.dart';
import '../timeline_extractor/timeline_extractor.dart';
import "package:ross_ai_1/auth/signin.dart";
import "package:ross_ai_1/auth/signup.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runZonedGuarded(
    () {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FirebaseAuthProvider()),
            ChangeNotifierProvider(
              create: (context) => TimelineExtractorProvider(),
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      // Handle errors here, such as logging them to a service
      print('Caught error: $error');
      print('Stack trace: $stackTrace');
    },
  );
  // Uncomment the line below if you want to run the app directly without error handling
  //
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Lato',
        appBarTheme: AppBarTheme(
          shadowColor: Colors.black,
          elevation: 1,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          // automaticallyImplyLeading: false
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: "Ross AI",
      home: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser != null) {
            return const HomePage();
          } else {
            return const LandingPage();
          }
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/precedents': (context) => const PrecedentFinder(),
        '/timeline': (context) => const TimelineExtractor(),
        '/jurisdiction': (context) => const JurisdictionChecker(),
        '/profile': (_) => const ProfilePage(),
        '/preferences': (_) => const PreferencesPage(),
        '/feedback': (_) => const FeedbackPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
