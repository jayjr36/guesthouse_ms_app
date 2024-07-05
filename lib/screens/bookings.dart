import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_door_ms_app/services/auth_services.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  BookingsScreenState createState() => BookingsScreenState();
}

class BookingsScreenState extends State<BookingsScreen> {
  String? token;
  int? userId;
  bool isloading = false;
  AuthService apiService = AuthService();
  late Future<List<dynamic>> _futureBookings;

  @override
  void initState() {
    super.initState();
    loadpreferences();
    _futureBookings = Future.value([]);
  }

  loadpreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      
    token = prefs.getString('token');
    userId = prefs.getInt('user_id');
    
    });
    _futureBookings =
        apiService.fetchUserBookings(token!, userId: userId);
  }

  Future<List<dynamic>> refreshBookings() async {
    setState(() {
      isloading = true;
      _futureBookings = apiService.fetchUserBookings(token!, userId: userId);
    });
    setState(() {
      isloading = false;
    });
    return _futureBookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found'));
          } else {
            List<dynamic> bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                Booking booking = Booking.fromJson(bookings[index]);
                return ListTile(
                  title: Text('Room ${booking.roomId}'),
                  subtitle: Text(
                      'Password: ${booking.password}\nExpires at: ${DateFormat.yMd().add_jm().format(DateTime.parse(booking.expiresAt))}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Booking {
 // final int id;
  final String roomId;
  final String password;
  final String expiresAt;

  Booking({
  //  required this.id,
    required this.roomId,
    required this.password,
    required this.expiresAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
     // id: json['id'] ?? '',
      roomId: json['room_number'],
      password: json['password'],
      expiresAt: json['expiry_time'],
    );
  }
}
