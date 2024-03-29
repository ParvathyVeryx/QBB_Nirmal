import 'dart:convert';
import 'package:QBB/screens/pages/erorr_popup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> callUpdatePasswordAPI(
    String qid, BuildContext context) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String lang = pref.getString("langEn").toString();
    String setLang;
    if (lang == "true") {
      setLang = "en";
    } else {
      setLang = "ar";
    }

    // Replace the following URL with your actual API endpoint
    final apiUrl =
        'https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/UpdatePasswordAPI?QID=$qid&language=$setLang';

    // Get the token from shared preferences
    String token = pref.getString('token') ?? ''; // Replace with your token key

    print('API URL: $apiUrl');
    print('Bearer Token: $token');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${token.replaceAll('"', '')}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse and return the data
      print('API Response Body: ${response.body}');
      showDialog(
          context: context, // Use the context of the current screen
          builder: (BuildContext context) {
            return ErrorPopup(errorMessage: response.body);
          });
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response, handle errors
      print('API Error Response: ${response.body}');
      showDialog(
          context: context, // Use the context of the current screen
          builder: (BuildContext context) {
            return ErrorPopup(errorMessage: response.body);
          });
      throw Exception(
          'Failed to call UpdatePasswordAPI: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during API request: $e');
    throw Exception('Exception during API request: $e');
  }
}
