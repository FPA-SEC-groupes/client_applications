import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/product.dart';
import '../interceptors/dio_interceptor.dart';
import '../models/category.dart';
import '../models/space.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class MenuViewModel{

  final DioInterceptor dioInterceptor;
  MenuViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<List<Category>> getCategoriesByIdSpace(String spaceId) async {
    try {
      final response = await dioInterceptor.dio.get('$baseUrl/api/categories/id_space/$spaceId');
      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Category> categories = parsedJson.map((json) => Category.fromJson(json)).toList();
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (error) {
      if (error is DioError) {
        if (error.response?.statusCode == 401) {
          // Handle 401 error here
          print('Unauthorized request. Please login again.');
          // Perform additional actions such as clearing session data or redirecting to a login screen
          // You can also show a dialog or display the message in your UI here
          throw Exception('Unauthorized request');
        } else {
          // Handle other types of DioError
          print('DioError occurred: ${error.message}');
          throw Exception('Failed to load categories: ${error.message}');
        }
      } else {
        // Handle other types of errors
        print('Error occurred: $error');
        throw Exception('Failed to load categories: $error');
      }
    }

  }
  Future<List<Product>> getProductsByIdCategory(int categoryId) async {
    try {
      final response = await dioInterceptor.dio
          .get('$baseUrl/api/products/all/dto/id_categorie/$categoryId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<Product> products =
        parsedJson.map((json) => Product.fromJson(json)).where((product) => product.available == true).toList();
        return products;
      }else {
        // Handle other HTTP errors
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 404) {
        return [];
      } else {
        throw Exception("Failed to load products" + error.toString());
      }
    } catch (error) {
      throw Exception(error);
    }
  }






  Future<Space> getSpaceById(String spaceId) async {
      final response = await dioInterceptor.dio.get('$baseUrl/api/spaces/id/$spaceId');

      if (response.statusCode == 200) {
        print(response.data);
        final space=Space.fromJson(response.data);
        return space;
      } else {
        // Handle HTTP error
        throw Exception('Failed to load space: ${response.statusCode}');
      }

  }

  Future<void> addRatingToSpace(double rate, int spaceId) async {
    try {

      Response response = await dioInterceptor.dio.post(
        '$baseUrl/api/spaces/add/rate/$spaceId',
        queryParameters: {'rate': rate,},
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Rating added successfully
        print('Rating added successfully');
      } else {
        // Handle other status codes if needed
        print('Failed to add rating. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that may occur during the request
      print('Error occurred: $e');
    }
  }
}