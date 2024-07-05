import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:smart_door_ms_app/screens/payment_screen.dart';
import 'package:smart_door_ms_app/services/api.dart';

class RoomSelectionPage extends StatefulWidget {
  const RoomSelectionPage({super.key});

  @override
  RoomSelectionPageState createState() => RoomSelectionPageState();
}

class RoomSelectionPageState extends State<RoomSelectionPage> {
  List rooms = [];
  int selectedDays = 1;
  double pricePerDay = 10000.0;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  void fetchRooms() async {
    setState(() {
      isloading = true;
    });

    final response = await http.get(
      Uri.parse(ApiServices().baseUrl + ApiServices().rooms),
      headers: <String, String>{
        'Accept': 'application/json',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        rooms = jsonDecode(response.body);
        isloading = false;
      });
    } else {
      print(response.body);
      setState(() {
        isloading = false;
      });
    }
  }

  void selectRoom(BuildContext context, String room) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaymentPage(room, selectedDays, pricePerDay * selectedDays)),
    );
  }

  bool isloading = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Rooms Available',
        style: TextStyle(color: Colors.deepOrange),
      )),
      body: LoadingOverlay(
        isLoading: isloading,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => selectRoom(context, rooms[index]['number']),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Room ${rooms[index]['number']}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Number of Days:'),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: selectedDays,
                    items: List.generate(30, (index) => index + 1)
                        .map((e) => DropdownMenuItem<int>(
                              value: e,
                              child: Text('$e'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDays = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordPage extends StatelessWidget {
  final int password;
  final String expiryTime;

  const PasswordPage(this.password, this.expiryTime, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Password: $password'),
            Text(expiryTime),
          //  CountdownTimer(expiryTime as DateTime),
          ],
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime expiryTime;

  const CountdownTimer(this.expiryTime, {super.key});

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  Duration? remainingTime;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.expiryTime.difference(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = widget.expiryTime.difference(DateTime.now());
        if (remainingTime!.isNegative) {
          timer.cancel();
          // Revert to default password
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        'Time remaining: ${remainingTime!.inMinutes}:${remainingTime!.inSeconds % 60}');
  }
}
