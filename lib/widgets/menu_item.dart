import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way_client/utils/const.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../res/app_colors.dart';
import '../models/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuCard extends StatefulWidget {
  final Product product;
  final void Function()? onTap;

  const MenuCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  _MenuCardState createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 140,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FittedBox(
                fit: BoxFit.fill,
                child: widget.product.images?.isEmpty == true
                    ? Icon(
                  Icons.image_outlined,
                  color: gray.withOpacity(0.5),
                )
                    : Image.network(
                  baseUrl+productUrl+widget.product.images![widget.product.images!.length - 1].fileName, // Assuming the last image's URL is accessed this way
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
          Expanded(
            child: Container(
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.product.title.substring(0, 1).toUpperCase() +
                                widget.product.title.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onTap,
                            child: Container(
                              width: 25.0,
                              height: 25.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: orange,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Text(
                          widget.product.description,
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : gray,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      widget.product.hasActivePromotion!
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${(widget.product.price * (100 - widget.product.percentage!)) / 100} DT",
                                style: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "(",
                                style: TextStyle(color: gray),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    "${widget.product.price} DT",
                                    style: TextStyle(color: gray),
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
                                style: TextStyle(color: gray),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "- ${widget.product.percentage}%",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                          : Text(
                        "${widget.product.price} DT",
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
