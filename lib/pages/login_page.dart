import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_pswd_page.dart';

class LoginPage extends StatefulWidget {
  //VoidCallback is a funciton that returns nothing
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController =
      TextEditingController(); //controller/keyboard for email input
  final _passwordController =
      TextEditingController(); //controller/keyboard for password input
  Future signIn() async {
    //loading circle

    //checks if email and password fields are empty first before checking if user exists and the password is valid for that user
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email'),
            duration: Duration(seconds: 1)),
      );
      return;
    } else if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your password'),
            duration: Duration(seconds: 1)),
      );
      return;
    } else {
      //otherwise both fields are filled check if crediential is correct
      try {
        //if an exception is generated within try block, catch block would be executed to handle exception
        showDialog(
          context: context,
          builder: (contex) {
            return const Center(
                child: CircularProgressIndicator()); //showing circular loading
          },
        );
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          //possible exception
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          //if email is NOT in firebase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No user found for that email.'),
                duration: Duration(seconds: 1)),
          );
          Navigator.of(context).pop(); //ending circular loading
        } else if (e.code == 'wrong-password') {
          //if password is wrong and email IS in firebase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Wrong password provided for that user.'),
                duration: Duration(seconds: 1)),
          );
          Navigator.of(context).pop(); //ending circular loading
        }
      }
    }
  }

  @override
  void dispose() {
    //to avoid memory leadks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                //formatting icons to be part of the title
                children: const [
                  SizedBox(width: 118),
                  Icon(
                    Icons.android,
                    color: Colors.green,
                  ),
                  SizedBox(width: 72),
                  Icon(
                    Icons.apple,
                    color: Colors.grey,
                  ),
                ],
              ),
              //into text
              const Text(
                'L I S T I F Y', //project name
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    fontFamily:
                        'Times', // replace with your desired font family
                    decoration: TextDecoration.underline,
                    color: Colors.blue // replace with your desired color
                    ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      //not clicked
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      //clicked
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Email',
                    fillColor: Colors.orange[50],
                    filled: true,
                  ),
                  controller: _emailController,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Password',
                    fillColor: Colors.orange[50],
                    filled: true,
                  ),
                  obscureText: true,
                  controller: _passwordController,
                ),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 125),
                child: Material(
                  color: Colors.amber[900],
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Center(
                        child: Text(
                          'Sign-in',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              //prompt user to register for account if new
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not registered? ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    //onTap would negate showLoginPage bool value in auth_page.dart
                    onTap: widget.showRegisterPage,
                    child: const Text(
                      'click here',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
