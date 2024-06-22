import 'package:hello_way_client/models/ProductStatus.dart';

import '../models/product.dart';


class ProductWithQuantities {
  final Product product;
  final int quantity;
  final int oldQuantity;
  final ProductStatus status;
  ProductWithQuantities( {required this.product,required this.quantity,required this.oldQuantity,required this.status,});

  factory ProductWithQuantities.fromJson(Map<String, dynamic> json) {
    return ProductWithQuantities(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      oldQuantity: json['oldQuantity'],
      status: ProductStatus.values.firstWhere((e) => e.toString() == 'ProductStatus.${json['status']}'),
    );
  }
  @override
  String toString() {
    return 'ProductWithQuantities{product: $product, quantity: $quantity}';
  }
}