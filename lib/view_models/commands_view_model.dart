


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/command.dart';

import '../interceptors/dio_interceptor.dart';
import '../response/product_with_quantity.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class CommandsViewModel {
  final DioInterceptor dioInterceptor;
  CommandsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();

Future<List<Command>?> getCommandsByUserId() async {
  final userId = await secureStorage.readData(authentifiedUserId);
  try {
    final response = await dioInterceptor.dio.get('$baseUrl/api/commands/by/user/$userId');

    if (response.statusCode == 200) {
      final List<dynamic> parsedJson = response.data;
      print(parsedJson);
      final List<Command> commands =
      parsedJson.map((json) => Command.fromJson(json))
          .toList();
      return commands;
    }
    else
{
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } on DioError catch (error) {
    if (error.response?.statusCode == 400) {

      return null;

    } else {
      print(error.response?.statusCode);
      throw Exception(error);
    }
  } catch (error) {
    throw Exception(error);
  }
}



  Future<double> getSumOfCommand(int commandId) async {
    try {
      final response = await await dioInterceptor.dio.get('$baseUrl/api/commands/calculate/sum/$commandId');

      if (response.statusCode == 200) {
        return response.data as double;
      } else {
        // Handle other status codes
        return 0.0;
      }
    } catch (e) {
      // Handle exceptions
      return 0.0;
    }
  }



  Future<List<ProductWithQuantities>> getProductsByCommandId(int commandId) async {
    try {
      final response =
      await dioInterceptor.dio.get('$baseUrl/api/baskets/products/by_command/$commandId');

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<ProductWithQuantities> products = parsedJson.map((json) => ProductWithQuantities.fromJson(json)).toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }



}