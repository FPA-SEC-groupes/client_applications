

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../interceptors/dio_interceptor.dart';
import '../models/notifcation.dart'as notif;
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import '../utils/const.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'dart:convert';

class NotificationViewModel{

  final DioInterceptor dioInterceptor;
  NotificationViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);
  final SecureStorage secureStorage = SecureStorage();
  static Future<String> translate(String message, String toLanguageCode) async {
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$apiKey&q=$message') ,
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;

      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }
  Future<List<notif.Notification>> fetchNewNotificationsForUser(String userId) async {
    final Dio dio = Dio();
    final String url = '$baseUrl/api/notifications/providers/$userId/notifications';
    final jwtCookie = await secureStorage.readData('jwtToken');
    String? savedLanguageCode = await secureStorage.readData('selectedLanguage');
    final options = Options(headers: {'Cookie': jwtCookie});

    try {
      final response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<notif.Notification> notifications = await Future.wait(
          parsedJson.map((json) async {
            final notification = notif.Notification.fromJson(json);
            notification.title = await translate(notification.title, savedLanguageCode ?? 'en');
            notification.message = await translate(notification.message, savedLanguageCode ?? 'en');
            return notification;
          }).toList(),
        );

        return notifications.where((notification) => !notification.seen).toList();
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
  Future<void> markAllNotificationsAsSeen() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    final String url = '$baseUrl/api/notifications/providers/$userId/mark-seen';

    try {
      final response = await dioInterceptor.dio.put(url);
      if (response.statusCode == 200) {
        print('All notifications marked as seen');
        await secureStorage.writeData(nbNewNotifications, "0"); // Reset unseen notifications
      } else {
        print('Failed to mark notifications as seen');
      }
    } catch (error) {
      print('Error marking notifications as seen: $error');
    }
  }

  Future<List<notif.Notification>> fetchNotificationsForUser(String userId) async {

    final String url = '$baseUrl/api/notifications/providers/$userId/notifications';


    String? savedLanguageCode = await secureStorage.readData('selectedLanguage');

    final response = await dioInterceptor.dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<notif.Notification> notifications = await Future.wait(
          parsedJson.map((json) async {
            final notification = notif.Notification.fromJson(json);
            notification.title = await translate(notification.title, savedLanguageCode ?? 'en');
            notification.message = await translate(notification.message, savedLanguageCode ?? 'en');
            return notification;
          }).toList(),
        );

        return notifications.where((notification) => !notification.seen).toList();
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