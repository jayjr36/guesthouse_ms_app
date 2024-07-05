import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_door_ms_app/services/api.dart';

class AuthService {
  Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse(ApiServices().baseUrl + ApiServices().register),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        // Successful registration
        return jsonDecode(response.body);
      } else {
        // Handle different status codes here
        return {
          'error': true,
          'message': 'Failed to register. Status code: ${response.statusCode}',
          'details': jsonDecode(response.body)
        };
      }
    } catch (e) {
      // Handle any errors that might occur during the request
      return {
        'error': true,
        'message': 'An error occurred during registration',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiServices().baseUrl + ApiServices().login),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        // Save user details and token to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setInt('user_id', responseData['user']['id']);
        await prefs.setString('user_name', responseData['user']['name']);
        await prefs.setString('user_email', responseData['user']['email']);
      } else {
        // Handle different status codes here
        return {
          'error': true,
          'message': 'Failed to login. Status code: ${response.statusCode}',
          'details': responseData
        };
      }

      return responseData;
    } catch (e) {
      // Handle any errors that might occur during the request
      return {
        'error': true,
        'message': 'An error occurred during login',
        'details': e.toString(),
      };
    }
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse(ApiServices().baseUrl + ApiServices().logout),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  Future<List<dynamic>> fetchUserBookings(String token, {int? userId}) async {
    final Uri uri =
        Uri.parse(ApiServices().baseUrl + ApiServices().userBookings)
            .replace(queryParameters: {
      'userId': userId?.toString(), // Include userId if it's not null
    });

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user bookings');
    }
  }
}
