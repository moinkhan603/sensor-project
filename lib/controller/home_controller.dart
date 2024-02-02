import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;

class HomeScreenViewModel extends BaseViewModel {
  bool isDataCollectionEnabled = false;
  List<Map<String, dynamic>> sensorData = [];

  double? heading;
  bool isInternetActive = true;

  void initialize(BuildContext context) {}

  @override
  void dispose() {
    super.dispose();
  }

  void startSensorDataCollection() {
    if (isDataCollectionEnabled) {
      Timer.periodic(Duration(seconds: 2), (Timer timer) async {
        if (isDataCollectionEnabled) {
          sensorData.add({
            'azimuth': heading?.ceil(),
            'timestamp': DateTime.now().toUtc().toString(),
          });
          saveDataToStorage();
          loadDataFromStorage();
          if (await isInternetConnected()) {
            sendSensorDataToAPI();
          }
        }
      });
    }
  }

  void sendSensorDataToAPI() async {
    if (isDataCollectionEnabled && sensorData.isNotEmpty) {
      try {
        if (sensorData.length >= 10) {
          // Take the first 10 elements and create a sublist
          List<Map<String, dynamic>> dataToSend =
              List.from(sensorData.take(10));

          // Remove the first 10 elements from the original list
          sensorData.removeRange(0, 10);

          // Send the data to the API
          await sendDataToAPI(dataToSend);
        }
      } catch (e) {
        print('Failed to send data to API: $e');
      }
    }
  }

  Future<void> sendDataToAPI(List<Map<String, dynamic>> dataToSend) async {
    final apiUrl = 'http://192.168.0.102:8080/log';
    final jsonData = jsonEncode(dataToSend);

    final response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'}, body: jsonData);

    if (response.statusCode != 200) {
      print('Failed to send data to API. Status code: ${response.statusCode}');
    }
  }

  Future<bool> isInternetConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  void saveDataToStorage() async {
    print('data saving');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sensorData', jsonEncode(sensorData));
  }

  void loadDataFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sensorData');
    if (savedData != null) {
      sensorData = jsonDecode(savedData).cast<Map<String, dynamic>>();
      print(sensorData.last['azimuth']);
      print(sensorData.last['timestamp']);
    }
  }
}
