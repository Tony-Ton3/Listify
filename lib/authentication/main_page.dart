import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'auth_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //StreamBuilder takes a stream of data as its input 
      body: StreamBuilder<User?>(
        //fill stream with authStateChanges from Firebase auth
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //checks if user is already logged in or not by taking a snapshot of stream 
          //and seeing if there is a event received on the stream
          if (snapshot.hasData) { //if snapshot has data it means user has already logged in 
            return const HomePage();
          } else { //otherwise bring user to authPage
            return const AuthPage();
          }
        },
      ),
    );
  }
}
