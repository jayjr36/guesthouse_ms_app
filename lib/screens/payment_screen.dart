// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_door_ms_app/screens/home_screen.dart';
import 'package:smart_door_ms_app/screens/rooms.dart';
import 'package:smart_door_ms_app/services/api.dart';

class PaymentPage extends StatefulWidget {
  final String room;
  final int days;
  final double amount;

  PaymentPage(this.room, this.days, this.amount, {super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();

  final TextEditingController expiryDateController = TextEditingController();

  final TextEditingController cvvController = TextEditingController();
  String? token;
  int? userId;
  @override
  void initState() {
    super.initState();
    loadprefrences();
  }

  loadprefrences() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userId = prefs.getInt('user_id');
  }

  void makePayment(BuildContext context) async {
    setState(() {
      isloading = true;
    });

    final response = await http.post(
      Uri.parse(ApiServices().baseUrl + ApiServices().bookRoom),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'room': widget.room,
        'days': widget.days.toString(),
        'amount': widget.amount.toString(),
        'card_number': cardNumberController.text,
        'expiry_date': expiryDateController.text,
        'cvv': cvvController.text,
        'user_id': userId
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isloading = false;
      });
      final data = jsonDecode(response.body);
      final password = data['password'];

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        isloading = false;
      });
      print(response.body);
      // Handle error
    }
  }

  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: LoadingOverlay(
        isLoading: isloading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Room: ${widget.room}'),
              Text('Days: ${widget.days}'),
              Text('Amount: TZS ${widget.amount}'),
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
              ),
              TextField(
                controller: expiryDateController,
                decoration: const InputDecoration(labelText: 'Expiry Date'),
              ),
              TextField(
                controller: cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                obscureText: true,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => makePayment(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange),
                  child: const Text(
                    'Pay',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
