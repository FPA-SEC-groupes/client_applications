import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/product.dart';
import 'package:hello_way_client/utils/const.dart';
import 'package:hello_way_client/utils/routes.dart';
import 'package:provider/provider.dart';
import '../../res/app_colors.dart';
import '../res/strings.dart';
import '../services/network_service.dart';
import '../view_models/basket_view_model.dart';
import '../widgets/snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_provider.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({Key? key}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late final BasketViewModel _basketViewModel;
  final GlobalKey<ScaffoldMessengerState> _detailsProductScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  int quantity = 1;

  @override
  void initState() {
    _basketViewModel = BasketViewModel(context);
    super.initState();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    print(product.toString());
    return ScaffoldMessenger(
      key: _detailsProductScaffoldKey,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.details),
          backgroundColor: orange,
        ),
        body: networkStatus == NetworkStatus.Online
            ? Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: ClipRRect(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: product.images?.isEmpty == true
                            ? Icon(
                          Icons.image_outlined,
                          color: gray.withOpacity(0.5),
                        )
                            :
                        Image.network(
                          baseUrl+productUrl+product.images![0].fileName, // Assuming product.images![0].url holds the image URL
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: gray.withOpacity(0.5),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: Text(
                      product.title.substring(0, 1).toUpperCase() +
                          product.title.substring(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: Text(
                      AppLocalizations.of(context)!.description,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      product.description,
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: Row(
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.price}: ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        product.hasActivePromotion!
                            ? Row(
                          children: [
                            Text(
                              "${(product.price * product.percentage!) / 100} ${AppLocalizations.of(context)!.tunisianDinar}",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "(",
                              style: TextStyle(fontSize: 16, color: gray),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "${product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                                  style: const TextStyle(fontSize: 16, color: gray),
                                  textAlign: TextAlign.center,
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 1,
                                    color: gray,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              ")",
                              style: TextStyle(fontSize: 16, color: gray),
                            ),
                            const SizedBox(width: 20),
                            Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "- ${product.percentage}%",
                                  style: const TextStyle(color: Colors.white),
                                ))
                          ],
                        )
                            : Text(
                          "${product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        decrementQuantity();
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: quantity > 1 ? orange : gray,
                            width: 1.0,
                          ),
                          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            color: quantity > 1 ? orange : gray,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        incrementQuantity();
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: orange,
                            width: 1.0,
                          ),
                          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: orange,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: orange,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _basketViewModel
                                .addProductToBasket(product.id!, quantity)
                                .then((_) {
                              var snackBar = customSnackBar(context, AppLocalizations.of(context)!.cartUpdatedSuccess, Colors.green);
                              _detailsProductScaffoldKey.currentState?.showSnackBar(snackBar);
                              Navigator.pushNamed(context,  menuRoute);
                            }).catchError((error) {
                              print(error);
                            });
                          },
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                AppLocalizations.of(context)!.addToCart,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.network_check,
                  size: 150,
                  color: gray,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.noInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppLocalizations.of(context)!.checkYourInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  color: orange,
                  height: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
