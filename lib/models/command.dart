

import 'package:hello_way_client/models/basket.dart';

class Command {
  int idCommand;
  String status;
  DateTime localDate;
  double sum;
  Basket? basket;

  Command({
    required this.idCommand,
    required this.status,
    required this.localDate,
    required this.sum,
    this.basket,
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      idCommand: json['idCommand'],
      status: json['status'],
      localDate: DateTime.parse(json['timestamp']),
      sum: json['sum'],
      basket: json['basket'] != null ? Basket.fromJson(json['basket']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCommand': idCommand,
      'status': status,
      'timestamp': localDate.toIso8601String(),
      'sum': sum,
      'basket': basket?.toJson(),
    };
  }
}