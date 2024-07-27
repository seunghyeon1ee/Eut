import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class GreetingProvider with ChangeNotifier {
  String greeting = '';

  Future<void> fetchGreeting() async {
    final response = await http.get(Uri.parse('http://3.38.165.93:8080/greeting'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      greeting = data['greeting_text'];
      notifyListeners();
    } else {
      throw Exception('Failed to load greeting');
    }
  }
}