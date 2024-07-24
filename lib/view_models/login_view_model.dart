

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/user.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class LoginViewModel{
  String token ="";
  final _firebaseMessaging= FirebaseMessaging.instance;
  final Dio dio = Dio();
  final url = '$baseUrl/api/auth/signin';
  final SecureStorage secureStorage = SecureStorage();

  Future<User> login(BuildContext context, String username,String password) async {
    try {
      String token = await _firebaseMessaging.getToken() ?? '';

      // Now update the state synchronously within setState
      Response response = await dio.post(
        url,
        data: jsonEncode({
          'username': username,
          'password': password,
          'token':token
        }),
      );





      if (response.statusCode == 200) {

        final data=response.data;
        final user = User.fromJson(data);
        await secureStorage.writeData(userIdKey,user.id.toString());
        await secureStorage.writeData(authentifiedUserId,user.id.toString());
        await secureStorage.writeData(numberOfRestrictions,user.numberOfRestrictions.toString());
        String? numberOfRestrictionsString = await secureStorage.readData(numberOfRestrictions);
        print(numberOfRestrictionsString);
        List<Cookie> cookies = response.headers.map['set-cookie']!
            .map((s) => Cookie.fromSetCookieValue(s))
            .toList();
        print(  response.headers['set-cookie']);
        for (Cookie cookie in cookies) {
          if (cookie.name == 'helloWay') {
            await secureStorage.writeData("jwtToken", cookie.toString());


          }
        }

        return user;

      } else {
        throw Exception("Login Failed");
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nom d\'utilisateur ou mot de passe incorect!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.blue));
          throw Exception("Failed to sign in");

      } else {
        print(error.response?.statusCode);
        throw Exception(error);
      }
    } catch (error) {
      throw Exception(error);
    }
  }



}

/*
  Future<String> testiniii() async {
    final jwtToken = await secureStorage.readData('jwtToken');

    final dio = Dio();

    try {
      final options = Options(
        headers: {
          'cookie': "hello-way-jwt=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0b3VhdGlpaTEyMyIsImlhdCI6MTY3ODg0NTIxOCwiZXhwIjoxNjc4ODQ1Mjc4fQ.sYq1MzrThEk7Mv42HpRMHrEhL2TPkZnX6sZMmBCSrmrRaUwo6ou3W6d3Ehs4BAnOJac2EMBaRxRQ58l8I3g98A", // replace with your cookie
        },
      );
      final response = await dio.get('http://192.168.186.214:8082/api/test/user',options: options);
      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      } else {
        print('Request failed with status: ${response.statusCode}');

        throw Exception("Failed to sign up");
      }
    } catch (e) {
      print('Request failed with error: $e');
      throw Exception("Failed to sign up");

    }
}*/


