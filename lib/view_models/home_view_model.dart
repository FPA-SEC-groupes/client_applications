import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/space.dart';

import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';

class HomeViewModel{
  final DioInterceptor dioInterceptor;
  HomeViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);


  final Dio dio=Dio();








  Future<List<Space>> getSpaces() async {
    final url = '$baseUrl/api/spaces/all/dto';
    try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = response.data;
      print(jsonData);
      final spaces = jsonData.map((json) => Space.fromJson(json)).toList();
      return spaces;
    } else {
      throw Exception('Failed to load spaces');
    }
  } catch (e) {
  // Handle other errors
  throw Exception('Failed to load spaces: $e');
  }
  }



  Future<List<Space>> getNearestSpacesByDistance(
      double userLatitude,
      double userLongitude,
      double distance,
      ) async {
    try {
      // Replace 'BASE_URL' with your actual API base URL
      final String apiUrl = '$baseUrl/api/spaces/nearest';

      final response = await dioInterceptor.dio.get(
        apiUrl,
        queryParameters: {
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
          'threshold': distance,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Space> spaces = data.map((e) => Space.fromJson(e)).toList();
        return spaces;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}