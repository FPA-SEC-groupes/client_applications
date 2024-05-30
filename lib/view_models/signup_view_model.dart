import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../res/app_colors.dart';
import '../response/message_response.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import 'login_view_model.dart';

class SignupViewModel {
  final Dio dio = Dio();

  final LoginViewModel _loginViewModel = LoginViewModel();
  Future<String> signup(BuildContext context, User user) async {
    final url = '$baseUrl/api/auth/signup';
    try {
      final response = await dio.post(
        url,
        data: user.toJson(),
      );

      final signupResponse = response.data['message'];

      if (response.statusCode == 200) {
        _loginViewModel.login(context, user.username,user.password!).then((_) {
          Navigator.pushNamed(context, bottomNavigationWithFABRoute);
          print("sucess");
        }).catchError((error) {
          print(error);
        });
        return signupResponse;

      } else {
        throw Exception("Failed to sign up");
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        final message = error.response?.data['message'];
        if (message == "Error: Username is already taken!") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Le nom d\'utilisateur est déjà utilisé!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ));
        } else if (message == "Error: Email is already in use!") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cet email est déjà utilisé!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erreur lors de l\'inscription!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ));
        }
        throw Exception("Failed to sign up");
      } else {
        throw Exception("Failed to sign up");
      }
    } catch (error) {
      throw Exception("Failed to sign up");
    }
  }
}
