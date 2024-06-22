import 'package:hello_way_client/models/ProductStatus.dart';

class BasketProducts {
  int idProduct;
  int quantity;
  ProductStatus status;

  BasketProducts({
    required this.idProduct,
    required this.quantity,
    required this.status,
  });


}
