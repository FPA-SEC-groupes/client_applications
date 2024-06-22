import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_way_client/utils/const.dart';

import '../interceptors/dio_interceptor.dart';
import '../../models/Restriction.dart';
import '../utils/secure_storage.dart';

class RestrictionsViewModel {
  final SecureStorage secureStorage = SecureStorage();

  final DioInterceptor dioInterceptor;
  RestrictionsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<int> getNumberOfRestrictionsByUserId(int userId) async {
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/restrictions/user/$userId');

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        throw Exception('Failed to load number of restrictions: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to load number of restrictions: $error');
    }
  }
}
