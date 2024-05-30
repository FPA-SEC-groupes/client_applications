import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../res/app_colors.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../widgets/alert_dialog.dart';

class DioInterceptor {
  final Dio dio = Dio();
  final SecureStorage secureStorage = SecureStorage();// Replace with your session ID key
  final BuildContext context;

  DioInterceptor(this.context) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final jwtCookie = await secureStorage.readData('jwtToken');
        final sessionId = await secureStorage.readData(sessionIdKey);

        final cookie = jwtCookie; // Replace with your cookie


        if (sessionId != null) {
          options.headers['cookie'] = 'JSESSIONID=$sessionId';
        }else{
          options.headers['cookie'] = cookie;
        }
        return handler.next(options);
      },

    onError: (DioError error, handler) async {
    if (error.response?.statusCode == 401) {
      Navigator.pushNamedAndRemoveUntil(context,bottomNavigationWithFABRoute, (route) => false);
      secureStorage.deleteAll();

    return ;
    }

    return handler.next(error);}


    ));
  }
}