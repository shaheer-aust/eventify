import 'package:eventify/homepage/dashboard.dart';
import 'package:eventify/homepage/home.dart';
import 'package:eventify/login%20and%20signup/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'firebase_options.dart';
import 'login and signup/signup.dart'; // Uncomment if using FlutterFire CLI for config

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
    // Uncomment if using firebase_options.dart
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventify-University Club Event Management',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: HomePage(),
      //initialRoute: '/home',
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}
