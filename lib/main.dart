import 'package:flutter/material.dart';
import 'package:ross_ai_1/jurisdiction_checker/jurisdiction_checker.dart';
import './home/home_page.dart';
import "package:ross_ai_1/profile/profile_page.dart";
import 'package:ross_ai_1/profile/components/feedback_page.dart';
import 'package:ross_ai_1/profile/components/preference_page.dart';
import '../precedent_finder/precedent_finder.dart';
import '../timeline_extractor/timeline_extractor.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
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
        )
      ),
      debugShowCheckedModeBanner: false,
      title: "Ross_AI",
      home: HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/precedents':(context)=> const PrecedentFinder(),
        '/timeline':(context)=> const TimelineExtractor(),
        '/jurisdiction':(context)=> const JurisdictionChecker(),
        '/profile': (_) => const ProfilePage(),
        '/preferences': (_) => const PreferencesPage(),
        '/feedback': (_) => const FeedbackPage(),
      },);

}
}