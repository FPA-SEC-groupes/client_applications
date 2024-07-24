import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/ProductStatus.dart';
import 'package:hello_way_client/utils/const.dart';
import '../res/app_colors.dart';
import '../response/product_with_quantity.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BasketItem extends StatefulWidget {
  final ProductWithQuantities productWithQuantity;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final void Function()? onDelete;

  const BasketItem({
    Key? key,
    required this.productWithQuantity,
    this.onDelete,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  _BasketItemState createState() => _BasketItemState();
}

class _BasketItemState extends State<BasketItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double? sum;
    String? formattedPrice;
    if(widget.productWithQuantity.product.hasActivePromotion ?? false)
    {
      sum = (widget.productWithQuantity.product.price * (100 - (widget.productWithQuantity.product.percentage ?? 0))) / 100;
      sum = double.parse(sum.toStringAsFixed(2));
      formattedPrice = "$sum ${AppLocalizations.of(context)!.tunisianDinar}";
    }
    else{
      sum = widget.productWithQuantity.product.price;
      sum= sum = double.parse(sum.toStringAsFixed(2));
      formattedPrice = "$sum ${AppLocalizations.of(context)!.tunisianDinar}";
    }
    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      height: 130,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: widget.productWithQuantity.product.images!.isEmpty
                        ? Icon(
                      Icons.image_outlined,
                      color: Colors.grey.withOpacity(0.5),
                    )
                        : Image.network(
                      baseUrl + productUrl + widget.productWithQuantity.product.images!.last.fileName,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productWithQuantity.product.title.substring(0, 1).toUpperCase() +
                            widget.productWithQuantity.product.title.substring(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                          formattedPrice!,
                        // "${(widget.productWithQuantity.product.price * (100 - (widget.productWithQuantity.product.percentage ?? 0))) / 100} DT",
                        style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                                InkWell(
                                  onTap:widget.productWithQuantity.quantity > widget.productWithQuantity.oldQuantity
                                      ? widget.onDecrement
                                      : null,
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: widget.productWithQuantity.quantity > 1
                                            ? Colors.orange
                                            : Colors.grey,
                                        width: 1.0,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.remove,
                                        color: widget.productWithQuantity.quantity > 1
                                            ? Colors.orange
                                            : Colors.grey,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  widget.productWithQuantity.quantity.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              InkWell(
                                onTap: widget.onIncrement,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.orange,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.productWithQuantity.status == ProductStatus.NEW)
                          InkWell(
                            onTap: widget.onDelete,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.delete,
                                  color: gray,
                                  size: 25,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: gray,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // else if (widget.productWithQuantity.status == ProductStatus.CONFIRMED)
                          // Text(''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
