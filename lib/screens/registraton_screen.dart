// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:smart_door_ms_app/screens/login_screen.dart';
import 'package:smart_door_ms_app/services/auth_services.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isloading = false;
  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final passwordConfirmation = _passwordConfirmationController.text;

      final response = await _authService.register(
          name, email, password, passwordConfirmation);

      if (response['success']) {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')));
      } else {
        setState(() {
          isloading = false;
        });
        // Handle registration error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Registration failed: ${response['message']}')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isloading,
        child: Padding(
          padding: EdgeInsets.all(h * 0.04),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: h * 0.1,
                ),
                const Center(
                  child: Text(
                    '      Guest House\nManagemant System',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),
                ),
                SizedBox(
                  height: h * 0.04,
                ),
                const Center(
                    child: Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordConfirmationController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Center(
                  child: Text(
                    'OR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => LoginScreen())),
                            (route) => false);
                      },
                      child: const Text(
                        'Signin To Your Account',
                        style: TextStyle(color: Colors.green),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }
}
