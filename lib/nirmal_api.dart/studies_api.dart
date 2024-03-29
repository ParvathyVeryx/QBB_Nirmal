import 'dart:convert';

// import 'package:QBB/providers/studymodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:QBB/providers/studymodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List locale = [
  {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
  {'name': 'عربي', 'locale': const Locale('ar')},
];

updateLanguage(Locale locale) {
  // Get.back();
  Get.updateLocale(locale);
}

Future<List<Study>> fetchStudyMasterAPI() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var lang = 'langChange'.tr;
  final String apiUrl =
      'https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/StudyMasterAPI';
  // const String token =
  // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im1vYmFkbWluQGdtYWlsLmNvbSIsIm5iZiI6MTcwMzE3ODA1MywiZXhwIjoxNzAzNzgyODUzLCJpYXQiOjE3MDMxNzgwNTMsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6NTAxOTEiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjUwMTkxIn0.WYN0dROXwe3ys9yA2Ngd62p7Fr2h6JV4nSyHPcnF4tk'; // Replace with your actual token
// Retrieve the token from SharedPreferences
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? token = pref.getString('token');
  String? qid = pref.getString('userQID');
  String? isLogin = pref.getString("studiesEN");

  try {
    final http.Response response = await http.get(
      Uri.parse('$apiUrl?QID=$qid&language=$lang'),
      headers: {
        'Authorization': 'Bearer ${token?.replaceAll('"', '')}',
      },
    );

    print('API URL: $apiUrl');
    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final List<Study> studies = responseData.map((data) {
        pref.setString("studyCode", data['Code'].toString());
        pref.setString("studyName", data['Name'].toString());
        pref.setString("studyDes", data['Description'].toString());
        pref.setString("Id", data['Id'].toString());
        return Study(
          Id: data['Id'] ?? '',
          studyCode:
              data['Code'] ?? '', // Check for null and provide a default value
          studyName:
              data['Name'] ?? '', // Check for null and provide a default value
          studyDescription: data['Description'] ??
              '', // Check for null and provide a default value
        );
      }).toList();

      return studies;
    } else {
      throw Exception('Failed to fetch data');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to fetch data. Error: $error');
  }
}

// Future<void> fetchAndSetStudies(BuildContext context) async {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   try {
//     List<Study> studies = await fetchStudyMasterAPI();

//     Provider.of<StudyProvider>(context, listen: false).setStudies(studies);
//   } catch (error) {
//     print('Error fetching studies: $error');
//     // Handle error as needed
//   }
// }
