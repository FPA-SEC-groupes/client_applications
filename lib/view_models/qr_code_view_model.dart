import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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



  Future<dynamic> setUserOnTheTable(String qrCode,

      ) async {
    // Display the QR code in a toast
    Position position = new Position(longitude:36.4959905, latitude:  10.5949871, timestamp: null, accuracy: 5, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);

    // Assuming accuracy is a separate measurement not provided in the SQL
    double accuracy = 5.0; // Example accuracy value, adjust as necessary

    // Define the API endpoint URL
    final url = '$baseUrl/api/auth/qr_Code_for_app_user/$qrCode/userLatitude/${position.latitude}/userLongitude/${position.longitude}/$accuracy';
    final response = await dioInterceptor.dio.post(url);

    // Handle the response from the API
    if (response.statusCode == 200) {
      if (response.data == "the user not in the space so we are sorry you cant be sated in this table") {
        Fluttertoast.showToast(
          msg: "data ${response.data}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
        );
        return false;
      } else {
        return response.data;
      }
    }
    return null; // Ensure the function returns a value on all code paths
  }


  final Dio dio = Dio();

  Future<dynamic> setGuestOnTheTable(String qrCode,
      // Position position,double accuracy
      ) async {




    Position position = new Position(longitude:36.4959905, latitude:  10.5949871, timestamp: null, accuracy: 5, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);

    // Assuming accuracy is a separate measurement not provided in the SQL
    double accuracy = 5.0; // Example accuracy value, adjust as necessary


    final url =
        '$baseUrl/api/auth/signin/qr_Code/$qrCode/userLatitude/${position.latitude}/userLongitude/${position.longitude}/${accuracy}';

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
}
