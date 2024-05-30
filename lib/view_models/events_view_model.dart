import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/event.dart';
import 'package:intl/intl.dart';

import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';

class EventsviewModel{

  final DioInterceptor dioInterceptor;
  EventsviewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  Future<List<Event>> getEventsByDateRange(DateTime startDate, DateTime endDate) async {

    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      Response response = await dioInterceptor.dio.get('$baseUrl/date-range',
          queryParameters: {'startDate': formattedStartDate, 'endDate': formattedEndDate},
      );

      if (response.statusCode == 200) {
        // API call successful, parse the data and return the list of events
        List<dynamic> data = response.data;
        List<Event> events = data.map((item) => Event.fromJson(item)).toList();
        return events;
      } else {
        // Handle other status codes if needed
        print('Error: ${response.statusCode}');
        throw Exception('Failed to load events');
      }
    } catch (e) {
      // Handle any exceptions that occur during the API call
      print('Error: $e');
      throw Exception('Failed to load events');
    }
  }
}