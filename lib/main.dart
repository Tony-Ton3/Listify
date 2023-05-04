import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_firebase/firebase_options.dart';
import 'authentication/main_page.dart';

void main() async {
//makes sure flutter framwork is initialized before initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  //initializes firebase with default options for current platform 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //creating instance of MyApp widget 
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//build would be called wherever the app needs to be rebuilt creating a new instance of MaterialApp
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      home: const MainPage(), 
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.blueAccent,
        ),
      ),
    );
  }
}
