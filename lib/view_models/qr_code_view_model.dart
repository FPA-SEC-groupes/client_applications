import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hello_way_client/models/WifiInfo.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/space.dart';
import '../models/user.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QrCodeViewModel {
  final SecureStorage secureStorage = SecureStorage();
  final DioInterceptor dioInterceptor;
  QrCodeViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<dynamic> setUserOnTheTable(String qrCode, position, accuracy) async {
    final url = '$baseUrl/api/auth/qr_Code_for_app_user/$qrCode/userLatitude/${position.latitude}/userLongitude/${position.longitude}/$accuracy';
    final response = await dioInterceptor.dio.post(url);

    // Handle the response from the API
    if (response.statusCode == 200) {
      if (response.data == "the user not in the space so we are sorry you cant be sated in this table") {
        return {'status': 'not_in_space'};
      } else if (response.data == "The table is not active.") {
        return {'status': 'table_not_active'};
      } else {
        return response.data;
      }
    }
    return null; // Ensure the function returns a value on all code paths
  }



  final Dio dio = Dio();

  Future<dynamic> setGuestOnTheTable(String qrCode, Position? position, double accuracy,
      ) async {

    final url =
        '$baseUrl/api/auth/signin/qr_Code/$qrCode/userLatitude/${position!.latitude}/userLongitude/${position!.longitude}/${accuracy}';

    var cookie= await secureStorage.readData('jwtToken');
    final response;
    if(cookie==null) {


      response = await dio.post(
        url,
      );
    }else{
      response = await dioInterceptor.dio.post(
        url,
      );

    }

    if (response.statusCode == 200) {

      print(response.data);

      if (response.data == "the user not in the space so we are sorry you cant be connected") {


        return false;
      } else {
        print(response.data);
        final user = User.fromJson(response.data);

        List<dynamic> cookies = response.headers.map['set-cookie']!
            .map((s) => Cookie.fromSetCookieValue(s))
            .toList();
        for (Cookie cookie in cookies) {
          if (cookie.name == 'helloWay') {
            await secureStorage.writeData("jwtToken", cookie.toString());

            print("passed cookie  " + cookie.toString());
          }
        }
        return user;


      }

    }
  }
  Future<dynamic> getSpaceValidationById(int spaceId) async {
    final url = '$baseUrl/api/auth/$spaceId/validation';

    try {
      final response = await dioInterceptor.dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      } else {

        return null;
      }
    } catch (e) {

      return null;
    }
  }
  Future<List<WifiInfo>> getWifisBySpaceId(int spaceId) async {
    final url = '$baseUrl/api/auth/space/$spaceId';

    try {
      final response = await dioInterceptor.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> wifiData = response.data;
        List<WifiInfo> wifis = wifiData.map((wifiJson) => WifiInfo.fromJson(wifiJson)).toList();
        return wifis;
      } else {
        Fluttertoast.showToast(
          msg: "Failed to get WiFis: ${response.statusCode}",
          // ... other toast parameters
        );
        return []; // Return an empty list on failure
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error occurred: $e",
        // ... other toast parameters
      );
      return []; // Return an empty list on error
    }
  }

}
