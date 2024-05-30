

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/notifcation.dart'as notification;
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class NotificationViewModel{

  final DioInterceptor dioInterceptor;
  NotificationViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();

  Future<List<notification.Notification>> fetchNewNotificationsForUser(String userId) async {
    final Dio dio = Dio();
    final String url = '$baseUrl/api/notifications/providers/$userId/notifications';
    final jwtCookie = await secureStorage.readData('jwtToken');
    final options = Options(headers: {'Cookie': jwtCookie});

    try {
      final response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<notification.Notification> notifications =
        parsedJson.map((json) => notification.Notification.fromJson(json)).where((notification) => notification.seen == false)
            .toList();
        return notifications;
      } else {
        // Handle error cases here, such as invalid response status codes.
        throw Exception('Failed to load notifications');
      }
    } on DioError catch (e) {
      // Handle DioError
      if (e.response?.statusCode == 401) {
        // Handle 401 Unauthorized, for example, perform token refresh or prompt the user to log in again.
        // You can use a separate function for token refresh or any other relevant logic.
        secureStorage.deleteAll();
        throw Exception('Failed to load notifications: ${e.message}');

      } else {
        // Handle other DioError cases
        throw Exception('Failed to load notifications: ${e.message}');
      }
    } catch (e) {
      // Handle other potential exceptions or network errors
      throw Exception('Failed to load notifications: $e');
    }
  }


  Future<List<notification.Notification>> fetchNotificationsForUser(String userId) async {

    final String url = '$baseUrl/api/notifications/providers/$userId/notifications';



      final response = await dioInterceptor.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<notification.Notification> notifications =
        parsedJson.map((json) => notification.Notification.fromJson(json))
            .toList();
        return notifications;
      } else {
        // Handle error cases here, such as invalid response status codes.
        throw Exception('Failed to load notifications');
      }

  }
  Future<void> updateNotificationAPI(
  int notificationId, String title, message, bool seen,
  ) async {
    try {
      final String url = '$baseUrl/api/notifications/$notificationId';
      final response = await dioInterceptor.dio.put(
        url,
        queryParameters: {
          'title': title,
          'message': message,
          'seen': seen.toString(),
        },
      );

      if (response.statusCode == 200) {
        // The update was successful
        print('Notification updated successfully');
        // You can handle the updated notification data here if needed
      } else {
        // Handle the error when the update was not successful
        print('Failed to update notification');
      }
    } catch (error) {
      // Handle any Dio errors
      print('Error: $error');
    }
  }

  Future<void> deleteNotification(int id) async {

    try {
      Response response = await dioInterceptor.dio.delete(
        '$baseUrl/api/notifications/$id',

      );

      if (response.statusCode == 200) {
        print('Notification deleted successfully');
      } else {
        print('Failed to delete notification');
        // Handle other response codes or errors
      }
    } catch (error) {
      print('An error occurred: $error');
      // Handle DioError or other exceptions
    }
  }

}