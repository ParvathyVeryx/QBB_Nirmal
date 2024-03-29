import 'dart:convert';

import 'package:QBB/screens/api/userid.dart';
import 'package:QBB/screens/pages/book_appointment_date_slot.dart';
import 'package:QBB/screens/pages/erorr_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// class ApiResponse {
//   final bool success;
//   final String message;
//   final dynamic data;

//   ApiResponse({required this.success, required this.message, this.data});

//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     return ApiResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: json['data'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'message': message,
//       'data': data,
//     };
//   }
// }
Future<void> bookAppointmentApiCall(
  BuildContext context,
  String studyId,
  String visitTypeId,
  String visitTypeName,
) async {
  String? qid = await getQIDFromSharedPreferences();

  if (qid != null) {
    print('QID: $qid');
  } else {
    print('Failed to retrieve QID');
  }
  int? personGradeId = await getPersonGradeIdFromSharedPreferences();

  if (personGradeId != null) {
    print('PersonGradeId: $personGradeId');
  } else {
    print('Failed to retrieve PersonGradeId');
  }

  const String apiUrl =
      'https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/BookAppointmentapi';

  final Map<String, dynamic> queryParams = {
    'qatarid': qid,
    'StudyId': studyId,
    'VisitTypeId': visitTypeId,
    'Pregnant': 'null',
    'PersonGradeId': personGradeId,
    'VisitName': visitTypeName,
    'page': '1',
    'language': 'langChange'.tr,
  };

  print('Study Parameters:');
  print('qatarid: ${queryParams['qatarid']}');
  print('StudyId: ${queryParams['StudyId']}');
  print('VisitTypeId: ${queryParams['VisitTypeId']}');
  print('Pregnant: ${queryParams['Pregnant']}');
  print('PersonGradeId: ${queryParams['PersonGradeId']}');
  print('VisitName: ${queryParams['VisitName']}');
  print('page: ${queryParams['page']}');
  print('language: ${queryParams['language']}');

  final Uri urinew = Uri.parse(
      "https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/GetReasonForCancelAppoinmentAPI?language=en");
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? token = pref.getString('token');
  final responsen = await http.get(
    urinew,
    headers: {
      'Authorization': 'Bearer ${token?.replaceAll('"', '')}',
      'Content-Type': 'application/json',
    },
  );
  print('gg1234' + responsen.body.toString());
  final Uri uri = Uri.parse(
      '$apiUrl?qatarid=${queryParams['qatarid']}&StudyId=${queryParams['StudyId']}&Pregnant=${queryParams['Pregnant']}&VisitTypeId=${queryParams['VisitTypeId']}&PersonGradeId=${queryParams['PersonGradeId']}&VisitName=${queryParams['VisitName']}&page=${queryParams['page']}&language=${queryParams['language']}');
  // SharedPreferences pref = await SharedPreferences.getInstance();
  // String? token = pref.getString('token');
  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token?.replaceAll('"', '')}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successful API call

      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Save the API response in shared preferences
      pref.setString('apiResponse', json.encode(jsonResponse));
      pref.setString("availableDates", json.encode(jsonResponse['datelist']));
      print('Available Dates' + pref.getString("availableDates").toString());

      String? jsonString = pref.getString("availableDates");

// Check if the jsonString is not null
      if (jsonString != null) {
        // Use json.decode to parse the jsonString
        dynamic decodedData = json.decode(jsonString);

        // Check if the decodedData is a List
        if (decodedData is List) {
          // Now you can use the data as a List
          List<String> availableDates = List<String>.from(decodedData);

          // Use the 'availableDates' list as needed
          print("Decoded List");
          print(availableDates);
        } else {
          print("Decoded data is not a List");
        }
      } else {
        print("No data found in SharedPreferences for 'availableDates'");
      }

      // Now, navigate to the AppointmentBookingPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppointmentBookingPage(),
        ),
      );
    } else {
      // Handle errors
      print('API Call Failed. Status Code: ${response.statusCode}');
      print('Error Message: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorPopup(errorMessage: response.body);
        },
      );
    }
  } catch (error) {
    // Handle network errors
    print('Error: $error');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorPopup(errorMessage: 'Network Error');
      },
    );
  }
}

Future<void> bookAppointmentToGetResults(
  BuildContext context,
  String Qid,
  String AppointmentTypeId,
  String AppoinmentId,
  String studyId,
  String visitTypeId,
  String availabilityCalendar,
) async {
  int? personGradeId = await getPersonGradeIdFromSharedPreferences();

  if (personGradeId != null) {
    print('PersonGradeId: $personGradeId');
  } else {
    print('Failed to retrieve PersonGradeId');
  }

  // const String apiUrl =
  //     'https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/BookResultAppointmentAPI';

  // SharedPreferences pref = await SharedPreferences.getInstance();
  // String? token = pref.getString('token');
  try {
    Map<String, dynamic> requestBody = {
      'qatarid': Qid,
      "AppointmentTypeId": AppointmentTypeId,
      "AppoinmentId": AppoinmentId,
      'StudyId': studyId,
      'AvailabilityCalenderId': visitTypeId,
      'AvailabilityCalenderId': availabilityCalendar,
      "ShiftCode": 'shft',
      'PersonGradeId': '$personGradeId',
      'language': 'langChange'.tr,
    };

    String apiUrl =
        "https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/BookResultAppointmentAPI?qatarid=${requestBody['qatarid']}&StudyId=${requestBody['StudyId']}&ShiftCode=${requestBody['ShiftCode']}&VisitTypeId=${requestBody['AvailabilityCalenderId']}&PersonGradeId=${requestBody['PersonGradeId']}&AvailabilityCalenderId=${requestBody['AvailabilityCalenderId']}&AppoinmentId=${requestBody['AppoinmentId']}&language=en&AppointmentTypeId=${requestBody['AppointmentTypeId']}";
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(apiUrl);
    String? token = pref.getString('token');

    final Uri uri = Uri.parse('$apiUrl');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${token?.replaceAll('"', '')}',
        'Accept': 'application/json'
      },
      // body: requestBody,
    );
    // print('00000000000000000000000000000000000');
    // print(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      // Successful API call

      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(response.body);
      // Save the API response in shared preferences

// Check if the jsonString is not null

      // Now, navigate to the AppointmentBookingPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppointmentBookingPage(),
        ),
      );
    } else {
      // Handle errors
      print('API Call Failed. Status Code: ${response.statusCode}');
      print('Error Message: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorPopup(errorMessage: response.body);
        },
      );
    }
  } catch (error) {
    // Handle network errors
    print('Error: $error');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorPopup(errorMessage: 'Network Error');
      },
    );
  }
}

Future<void> getResultAppointmentApiCall(
  BuildContext context,
  String studyId,
  String visitTypeId,
  String AppointmentId,
) async {
  String? qid = await getQIDFromSharedPreferences();

  if (qid != null) {
    print('QID: $qid');
  } else {
    print('Failed to retrieve QID');
  }
  int? personGradeId = await getPersonGradeIdFromSharedPreferences();

  if (personGradeId != null) {
    print('PersonGradeId: $personGradeId');
  } else {
    print('Failed to retrieve PersonGradeId');
  }

  const String apiUrl =
      'https://participantportal-test.qatarbiobank.org.qa/QbbAPIS/api/BookResultAppointmentAPI';

  final Map<String, dynamic> queryParams = {
    'qatarid': qid,
    'StudyId': studyId,
    'VisitTypeId': visitTypeId,
    'Pregnant': 'null',
    'PersonGradeId': personGradeId,
    'AppointmentId': AppointmentId,
    'page': '1',
    'language': 'langChange'.tr,
  };

  print('Study Parameters:');
  print('qatarid: ${queryParams['qatarid']}');
  print('StudyId: ${queryParams['StudyId']}');
  print('VisitTypeId: ${queryParams['VisitTypeId']}');
  print('Pregnant: ${queryParams['Pregnant']}');
  print('PersonGradeId: ${queryParams['PersonGradeId']}');
  print('AppointmentId: ${queryParams['AppointmentId']}');
  print('page: ${queryParams['page']}');
  print('language: ${queryParams['language']}');

  SharedPreferences pref = await SharedPreferences.getInstance();
  String? token = pref.getString('token');

  final Uri uri = Uri.parse(
      '$apiUrl?qatarid=${queryParams['qatarid']}&StudyId=${queryParams['StudyId']}&Pregnant=${queryParams['Pregnant']}&VisitTypeId=${queryParams['VisitTypeId']}&PersonGradeId=${queryParams['PersonGradeId']}&AppointmentId=${queryParams['AppointmentId']}&page=${queryParams['page']}&language=${queryParams['language']}');
  // SharedPreferences pref = await SharedPreferences.getInstance();
  // String? token = pref.getString('token');
  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token?.replaceAll('"', '')}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successful API call

      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const AppointmentBookingPage(),
      //   ),
      // );
    } else {
      // Handle errors
      print('API Call Failed. Status Code: ${response.statusCode}');
      print('Error Message: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorPopup(errorMessage: response.body);
        },
      );
    }
  } catch (error) {
    // Handle network errors
    print('Error: $error');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorPopup(errorMessage: 'Network Error');
      },
    );
  }
}
