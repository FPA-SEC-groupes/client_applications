import 'package:hello_way_client/models/image.dart';

class User {
  int? id;
  String username;
  String email;
  String? password;
  String? name;
  String? lastname;
  String? birthday;
  String? phone;
  String? sessionId;
  String? image;
  List<dynamic>? role;

  User({ required this.username,required this.email, this.password,this.role, this.phone,this.id, this.name,this.lastname,this.birthday,this.sessionId,this.image});


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'roles':role
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      lastname: json['lastname'],
      birthday: json['birthday'],
      image:json['image']!=null? json['image']['data']:null,
      email: json['email'],
      role: json['roles'],
      phone: json['phone'],
     sessionId: json['sessionId'],

    );
  }
}
