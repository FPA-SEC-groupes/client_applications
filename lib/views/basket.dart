import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_way_client/models/ProductStatus.dart';
import 'package:hello_way_client/response/product_with_quantity.dart';
import 'package:hello_way_client/utils/const.dart';
import 'package:provider/provider.dart';
import '../models/command.dart';
import '../models/user.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../shimmer/item_product_basket_shimmer.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/basket_view_model.dart';
import '../widgets/basket_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_provider.dart';

class Basket extends StatefulWidget {
  const Basket({super.key});

  @override
  State<Basket> createState() => _BasketState();
}

class _BasketState extends State<Basket> {
  final SecureStorage secureStorage = SecureStorage();
  late final BasketViewModel _basketViewModel;
  String? firstSession;
  double _totalSum = 0.0;
  int? commandId;
  Command? _command;

  @override
  void initState() {
    _basketViewModel = BasketViewModel(context);
    fetchCommandByBasketId();
    validateSessionForUsers();
    _getProductsByBasketId();
    _getTotalSumByBasketId();
    super.initState();
  }

  Future<Command?> fetchCommandByBasketId() async {
    Command? command = await _basketViewModel.fetchCommandByBasketId();
    commandId = command?.idCommand;
    _command = command;

    if (_command?.status == "PAYED") {
      Fluttertoast.showToast(
        msg: "Payed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushReplacementNamed(context, bottomNavigationWithFABRoute);
    }
    return command;
  }


  Future<List<ProductWithQuantities>> _getProductsByBasketId() async {
    List<ProductWithQuantities> products = await _basketViewModel.getProductsByBasketId();
    return products;
  }

  Future<double> _getTotalSumByBasketId() async {
    List<ProductWithQuantities> products = await _basketViewModel.getProductsByBasketId();
    double totalSum = 0;
    for (var product in products) {
      var productDetails = product.product;
      if (productDetails != null) {
        bool hasActivePromotion = productDetails.hasActivePromotion ?? false;
        double productPrice = hasActivePromotion
            ? productDetails.price * (100 - (productDetails.percentage ?? 0)) / 100
            : productDetails.price;
        int productQuantity = product.quantity-product.oldQuantity;
        double productSum = productPrice * productQuantity;
        totalSum += productSum;
      }
    }

    setState(() {
      _totalSum = totalSum;
    });
    return totalSum;
  }

  Future<void> validateSessionForUsers() async {
    final tableId = await secureStorage.readData(tableIdKey);
    final session = await _basketViewModel.validateSessionForUsers(tableId!);
    setState(() {
      firstSession = session;
    });
  }
  Future<void> _showDeleteConfirmationDialog(ProductWithQuantities product) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteConfirmation),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.deleteTitle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () {
                _basketViewModel.deleteProductFromBasket(product.product.id!).then((_) {
                  setState(() {
                    _getTotalSumByBasketId();
                    _getProductsByBasketId();
                  });
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print(error);
                });
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.basket),
        backgroundColor: orange,
        actions: [
          commandId != null
              ? IconButton(
              icon: SvgPicture.asset(
                'assets/images/food_waiter.svg',
                height: 30,
                width: 30,
                color: Colors.white,
              ),
              onPressed: () async {
                await _basketViewModel.fetchServerByCommandId(commandId!).then((user) {
                  print(user);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                        actions: <Widget>[
                          MaterialButton(
                            color: orange,
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minWidth: double.infinity,
                            onPressed: () async {
                              await _basketViewModel
                                  .createNotification(user, AppLocalizations.of(context)!.callWaiter, AppLocalizations.of(context)!.tableServiceRequest.replaceAll('%numTable', "jjj"))
                                  .then((notification) {
                                Navigator.of(context).pop();
                              }).catchError((error) {
                                print(error);
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.callWaiter,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MaterialButton(
                            color: orange,
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minWidth: double.infinity,
                            onPressed: () async {
                              await _basketViewModel
                                  .createNotification(user, AppLocalizations.of(context)!.billRequest, AppLocalizations.of(context)!.billRequestMessage.replaceAll('%numTable', "xx"))
                                  .then((notification) {
                                Navigator.of(context).pop();
                              }).catchError((error) {
                                print(error);
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.billRequest,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MaterialButton(
                            color: orange,
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minWidth: double.infinity,
                            onPressed: () async {
                              await _basketViewModel.createNotification(user, "wal3a", "gggg").then((notification) {
                                Navigator.of(context).pop();
                              }).catchError((error) {
                                print(error);
                              });
                            },
                            child: const Text(
                              "wal3a",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialButton(
                            color: gray,
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minWidth: double.infinity,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).catchError((error) {
                  print(error);
                });
              })
              : const SizedBox()
        ],
      ),
      body: networkStatus == NetworkStatus.Online
          ? Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: _getProductsByBasketId(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return ItemProductBasketShimmer();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_basket_outlined,
                              size: 150,
                              color: gray,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!.emptyCartMessage,
                              style: const TextStyle(fontSize: 24, color: gray),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    final products = snapshot.data!;
                    return ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        ProductWithQuantities product = products[index];
                        return
                          BasketItem(
                          productWithQuantity: product,
                          onDelete: () {
                            _showDeleteConfirmationDialog(product);
                            // _basketViewModel.deleteProductFromBasket(product.product.id!).then((_) {
                            //   setState(() {
                            //     _getTotalSumByBasketId();
                            //     _getProductsByBasketId();
                            //   });
                            // }).catchError((error) {
                            //   print(error);
                            // });
                          },
                          onIncrement: () {
                            _basketViewModel.addProductToBasket(product.product.id!, 1,context).then((_) {
                              setState(() {
                                _getTotalSumByBasketId();
                              });
                            }).catchError((error) {
                              print(error);
                            });
                          },
                          onDecrement: () {
                            if (product.quantity > 1) {
                              _basketViewModel.addProductToBasket(product.product.id!, -1,context).then((_) {
                                setState(() {
                                  _getTotalSumByBasketId();
                                });
                              }).catchError((error) {
                                print(error);
                              });
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          color: themeProvider.isDarkMode ? Colors.grey[800] : lightGray,
                          height: 10,
                        );
                      },
                    );
                  }
                }),
          ),
          if (
          firstSession == "First session" &&
              _totalSum != 0.0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0), color: orange),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: MaterialButton(
                    onPressed: () async {
                      if (commandId == null) {
                        _basketViewModel.addNewCommand().then((command) async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.orderAddedSuccess),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.green,
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height -
                                    kToolbarHeight -
                                    44 -
                                    MediaQuery.of(context).padding.top,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          );

                          setState(() {
                            commandId = command.idCommand;
                          });
                          Navigator.pushReplacementNamed(context, listCommandsRoute);
                        }).catchError((error) {
                          print(error);
                        });
                      }
                      else{
                        _basketViewModel.addNewCommand().then((command) async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.orderAddedSuccess),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.green,
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height -
                                    kToolbarHeight -
                                    44 -
                                    MediaQuery.of(context).padding.top,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          );

                          setState(() {
                            commandId = command.idCommand;
                          });
                          Navigator.pushReplacementNamed(context, listCommandsRoute);
                        }).catchError((error) {
                          print(error);
                        });
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.orderModifiedSuccess),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.green,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height -
                                kToolbarHeight -
                                44 -
                                MediaQuery.of(context).padding.top,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        );
                        Navigator.pushReplacementNamed(context, listCommandsRoute);
                      }

                    },
                    child: Text(
                     commandId==null ?
                     AppLocalizations.of(context)!.confirmOrderMessage.replaceAll('%totalSum', _totalSum.toStringAsFixed(2))
                      :AppLocalizations.of(context)!.modifyOrderMessage.replaceAll('%totalSum', _totalSum.toStringAsFixed(2)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  )),
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
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
