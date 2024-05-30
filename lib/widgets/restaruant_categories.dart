import 'package:flutter/material.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SpaceCategories extends SliverPersistentHeaderDelegate {
  const SpaceCategories({
    Key? key,
    required this.onChanged,
    required this.selectedIndex,
    required this.items,
  });

  final ValueChanged<int> onChanged;
  final int selectedIndex;
  final List<Category> items;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: 52,
      color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      child: Categories(
        onChanged: onChanged,
        selectedIndex: selectedIndex,
        items: items,
      ),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}

class Categories extends StatefulWidget {
  const Categories({
    Key? key,
    required this.onChanged,
    required this.selectedIndex,
    required this.items,
  }) : super(key: key);

  final ValueChanged<int> onChanged;
  final int selectedIndex;
  final List<Category> items;

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Categories oldWidget) {
    _controller.animateTo(
      80.0 * widget.selectedIndex,
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.items.length,
              (index) => Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.selectedIndex == index ? orange : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {
                widget.onChanged(index);
              },
              style: TextButton.styleFrom(
                foregroundColor: widget.selectedIndex == index ? orange : (themeProvider.isDarkMode ? Colors.white70 : Colors.black45),
              ),
              child: Text(
                widget.items[index].categoryTitle
                    .substring(0, 1)
                    .toUpperCase() +
                    widget.items[index].categoryTitle.substring(1),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
