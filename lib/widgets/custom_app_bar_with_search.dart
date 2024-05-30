import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class CustomAppBarWithSearch extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final bool isSearching;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggle;

  const CustomAppBarWithSearch({
    required this.title,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: "Rechercher...",
          border: InputBorder.none,
        ),
      )
          : Text(title),
      elevation: 1,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: onSearchToggle,
            child: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
