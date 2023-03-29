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
    //toggle between login and register page by negating showLoginPage bool value
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  //on first start up, show the login page
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      //if user is registered
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      //if user is NOT registered
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
