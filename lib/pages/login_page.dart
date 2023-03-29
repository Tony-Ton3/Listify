import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  //VoidCallback is a function that takes no arguments and returns nothing
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 5,
      //   title: const Text("TO-DO"),
      //   centerTitle: true,
      // ),
      backgroundColor: Colors.orange[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.android),
                  SizedBox(width: 42),
                  Icon(Icons.apple),
                ],
              ),
              //into text
              const Text(
                'L O G I N',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Email',
                      fillColor: Colors.orange[50],
                      filled: true,
                    ),
                    controller: _emailController,
                  )
                  //username container for userinput
                  // child: Container(
                  //   decoration: BoxDecoration(
                  //       color: Colors.orange[50],
                  //       border: Border.all(color: Colors.black),
                  //       borderRadius: BorderRadius.circular(10)),
                  //   child: const Padding(
                  //     padding: EdgeInsets.only(left: 20),
                  //     child: TextField(
                  //       decoration: InputDecoration(
                  //         //gets rid of unwanted border
                  //         border: InputBorder.none,
                  //         hintText: "Username",
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25),
              //   //password container for userinput
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: Colors.orange[50],
              //         border: Border.all(color: Colors.black),
              //         borderRadius: BorderRadius.circular(10)),
              //     child: const Padding(
              //       padding: EdgeInsets.only(left: 20),
              //       child: TextField(
              //         obscureText: true,
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           hintText: "Password",
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 15),
              //login button
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 100),
              //   child: GestureDetector(
              //     onTap: signIn,
              //     child: Container(
              //       padding: const EdgeInsets.all(20),
              //       decoration: BoxDecoration(
              //           color: Colors.amber[900],
              //           border: Border.all(color: Colors.black),
              //           borderRadius: BorderRadius.circular(10)),
              //       child: const Center(
              //         child: Text(
              //           'Sign in',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 15,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 125),
                child: Material(
                  color: Colors.amber[900],
                  child: InkWell(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Center(
                        child: Text(
                          'Sign-in',
                          style: TextStyle(
                            color: Colors.white,
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
