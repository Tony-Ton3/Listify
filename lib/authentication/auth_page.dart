import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    //toggle between login and register page by negating a bollean value
    //setState notifies framework that the state needs to be rebuilt
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  //setState triggers build 
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {//on first start up user will see login page first 
      //toggle to register page if user needs to register 
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      //toggle back to login page if in register page 
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
