// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:smart_door_ms_app/providers/auth_providers.dart';
import 'package:smart_door_ms_app/screens/home_screen.dart';
import 'package:smart_door_ms_app/screens/registraton_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: isloading,
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(h*0.07),
            child: Column(
              children: [
          
                SizedBox(height: h*0.2,),
                const Center(
                  child: Text(
                    '      Guest House\nManagemant System',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
                SizedBox(height: h*0.04,),
                const Center(child: Text('Login To Your Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isloading = true;
                      });
                      await authProvider.login(
                          emailController.text, passwordController.text);
                      if (authProvider.isAuthenticated) {
                        setState(() {
                          isloading = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const HomeScreen())));
                      } else {
                        setState(() {
                          isloading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login failed')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange
                    ),
                    child: const Text('Login', style: TextStyle(color: Colors.white),),
                  ),
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const RegistrationPage())));
                      },
                      child: const Text('Create an account', style: TextStyle(color: Colors.green),)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
