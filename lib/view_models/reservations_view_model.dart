import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/reservation.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class ReservationsViewModel{
  final SecureStorage secureStorage = SecureStorage();

  final DioInterceptor dioInterceptor;
  ReservationsViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);



  Future<Reservation> addReservation(Reservation reservation,int spaceId) async {

    String? userId = await secureStorage.readData(authentifiedUserId);
    try {
      var response = await dioInterceptor.dio.post(
        '$baseUrl/api/reservations/space/$spaceId/user/$userId',
        data: reservation.toJson(), // Serialize reservation object to JSON
      );

      if (response.statusCode == 200) {
        var createdReservation = Reservation.fromJson(response.data);
        // Handle the created reservation object

        return createdReservation;
      } else {
        // Handle errors based on the response status code
        print('Error: ${response.statusCode}');

        throw Exception('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      throw Exception('Error: $error');
    }
  }



  Future<List<Reservation>> getReservationsByUserId() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    try {
      var response = await dioInterceptor.dio.get('$baseUrl/api/reservations/user/$userId');

      if (response.statusCode == 200) {
        var reservationList = (response.data as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
        return reservationList;
      } else {
        // Handle errors based on the response status code
        throw Exception('failed to load reservations: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Exception: $error');
      throw Exception('failed to load reservations: $error');
    }
  }


  Future<Reservation> cancelReservation(int reservationId) async {
    final url='$baseUrl/api/reservations/$reservationId/cancel';
    try {
      Response response = await dioInterceptor.dio.post(
        url, // Replace with your actual API endpoint URL
      );
      if (response.statusCode == 200) {
        print(response.data);
        Reservation updatedReservation = Reservation.fromJson(response.data);
        print('Reservation canceled successfully!');
        return updatedReservation;
      } else {
        throw Exception('failed to load');
      }
    } catch (error) {
      throw Exception('failed : $error');
    }
  }

}