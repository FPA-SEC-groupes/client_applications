import 'package:flutter/material.dart';
import 'package:hello_way_client/views/home.dart';
import 'package:hello_way_client/views/spaces_map_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/network_service.dart';
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final PageController _pageController = PageController(initialPage: 0);

  // Function to update the page index of the PageView
  void changePageIndex(int index) {
    setState(() {
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(

      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          Home(changePageIndex: changePageIndex),
          SpacesMapScreen(changePageIndex: changePageIndex),
        ],
      ),
    );
  }
}
