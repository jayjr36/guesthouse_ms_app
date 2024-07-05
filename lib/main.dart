import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_door_ms_app/providers/auth_providers.dart';
import 'package:smart_door_ms_app/screens/login_screen.dart';

void main() {
  runApp(
     ChangeNotifierProvider(
       create: (context) => AuthProvider(),
       child: const MyApp(),
     )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guest House Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  LoginScreen(),
    );
  }
}
