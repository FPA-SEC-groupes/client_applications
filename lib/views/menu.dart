import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/product.dart';
import 'package:hello_way_client/view_models/menu_view_model.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/space.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../shimmer/space_info_shimmer.dart';
import '../shimmer/tab_bar_shimmer.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/basket_view_model.dart';
import '../widgets/menu_item.dart';
import '../widgets/restaruant_categories.dart';
import '../widgets/snack_bar.dart';
import '../widgets/space_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_provider.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late MenuViewModel _menuViewModel;
  final scrollController = ScrollController();
  final SecureStorage secureStorage = SecureStorage();
  int selectedCategoryIndex = 0;
  double infoHeight = 420 + kToolbarHeight;
  List<Category>? _categories;
  List<List<Product>> listProducts = [];
  late String spaceId;
  Space? space;
  String? userId;
  double _rating = 0.0;

  late final BasketViewModel _basketViewModel;
  final GlobalKey<ScaffoldMessengerState> _addProductScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    _basketViewModel = BasketViewModel(context);
    _getSpaceById();
    _loadData();
    _menuViewModel = MenuViewModel(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
    _getSpaceById();
    print(listProducts);
    for (var prod in listProducts) {
      print(prod.toString());
    }
  }

  Future<void> _loadData() async {
    await loadData();
    createBreakPoints();
    scrollController.addListener(() {
      updateCategoryIndexOnScroll(scrollController.offset);
    });
  }

  Future<Space> _getSpaceById() async {
    userId = await secureStorage.readData(authentifiedUserId);
    final spaceId = await secureStorage.readData(spaceIdKey);
    final _space = await _menuViewModel.getSpaceById(spaceId!);
    setState(() {
      space = _space;
    });
    return _space;
  }

  Future<List<Category>?> loadData() async {
    final spaceId = await secureStorage.readData(spaceIdKey);
    final categories = await _menuViewModel.getCategoriesByIdSpace(spaceId!);
    final List<Category> categoriesWithProducts = [];
    final List<List<Product>> tempProductLists = [];

    for (var category in categories) {
      final products = await _menuViewModel.getProductsByIdCategory(category.id_category!);

      if (products.isNotEmpty) {
        categoriesWithProducts.add(category);
        tempProductLists.add(products);

        print(products);
      }
    }

    setState(() {
      _categories = categoriesWithProducts;
      listProducts = tempProductLists;
    });

    return _categories;
  }

  void scrollToCategory(int index) {
    if (selectedCategoryIndex != index) {
      int totalItems = 0;
      for (var i = 0; i < index; i++) {
        totalItems += listProducts[i].length;
      }
      scrollController.animateTo(
        infoHeight - 50 + (50 * index) + (150 * totalItems),
        duration: const Duration(milliseconds: 50),
        curve: Curves.ease,
      );
    }
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  List<double> breakPoints = [];

  void createBreakPoints() {
    if (listProducts.isNotEmpty) {
      double firstBreakPoint = infoHeight + 50 + (150 * listProducts[0].length);
      breakPoints.add(firstBreakPoint);
      for (var i = 1; i < listProducts.length; i++) {
        double breakPoint =
            breakPoints[i - 1] + 50 + (150 * listProducts[i - 1].length);
        breakPoints.add(breakPoint);
      }
    }
  }

  void updateCategoryIndexOnScroll(double offset) {
    if (offset < breakPoints.first && selectedCategoryIndex != 0) {
      setState(() {
        selectedCategoryIndex = 0;
      });
    } else {
      for (var i = 0; i < listProducts.length - 1; i++) {
        if (offset >= breakPoints[i] && offset < breakPoints[i + 1]) {
          if (selectedCategoryIndex != i + 1) {
            setState(() {
              selectedCategoryIndex = i + 1;
            });
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: orange,
        title: Text(
          AppLocalizations.of(context)!.menu,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, basketRoute);
          },
          backgroundColor: orange,
          child: const Icon(
            Icons.shopping_basket,
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          space != null
              ? SliverToBoxAdapter(
            child: SpaceInfo(
              space: space!,
              authentifiedUserId: userId,
              initialRating: _rating,
              onRatingUpdate: (rate) {
                setState(() {
                  _rating = rate;
                });
              },
              submit: () {
                _menuViewModel.addRatingToSpace(_rating, space!.id).then((space) async {
                  _getSpaceById();
                  Navigator.of(context).pop();
                }).catchError((error) {});
              },
            ),
          )
              : const SliverToBoxAdapter(child: SpaceInfoShimmer()),
          if (_categories != null)
            SliverPersistentHeader(
              delegate: SpaceCategories(
                onChanged: scrollToCategory,
                selectedIndex: selectedCategoryIndex,
                items: _categories!,
              ),
              pinned: true,
            )
          else
            const SliverToBoxAdapter(child: TabBarShimmer()),
          if (_categories != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final category = _categories![index];
                  return Container(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : lightGray,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                          child: Text(
                            category.categoryTitle.substring(0, 1).toUpperCase() +
                                category.categoryTitle.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (listProducts.length > index)
                          MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: listProducts[index].length,
                              itemBuilder: (BuildContext context, int itemIndex) {
                                final product = listProducts[index][itemIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    child: MenuCard(
                                      product: product,
                                      onTap: () {
                                        _basketViewModel.addProductToBasket(product.id!, 1).then((_) {}).catchError((error) {
                                          print(error);
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(context, productDetailsRoute, arguments: product);
                                    },
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          const CircularProgressIndicator(),
                      ],
                    ),
                  );
                },
                childCount: _categories!.length,
              ),
            )
          else
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
