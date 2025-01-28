import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way_client/utils/const.dart';
import 'package:provider/provider.dart';
import 'package:hello_way_client/widgets/rating_dialog.dart';

import '../models/space.dart';
import '../res/app_colors.dart';
import '../models/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SpaceInfo extends StatefulWidget {
  final Space space;
  final String? authentifiedUserId;
  final void Function(double) onRatingUpdate;
  final double initialRating;
  final void Function()? submit;

  const SpaceInfo({
    super.key,
    required this.space,
    required this.authentifiedUserId,
    required this.initialRating,
    required this.onRatingUpdate,
    this.submit,
  });

  @override
  State<SpaceInfo> createState() => _SpaceInfoState();
}

class _SpaceInfoState extends State<SpaceInfo> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> _pages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pages = widget.space.images!.isEmpty
            ? [
          const FittedBox(
            child: Icon(Icons.image_outlined, color: gray),
          )
        ]
            : List.generate(
          widget.space.images!.length,
              (index) => SizedBox(
            height: 50,
            child: ClipRRect(
              child: FittedBox(
                fit: BoxFit.fill,
                child:Image.network(baseUrl+spaceUrl+widget.space.images![index].fileName)
                // Image.memory(
                //   base64.decode(widget.space.images![index].data),
                // ),
              ),
            ),
          ),
        );
      });
      startTimer();
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_currentPage < _pages.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[850] : lightGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                child: PageView(
                  controller: _pageController, // Attach the PageController to the PageView
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: _pages,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 10,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_pages.length, (int index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 10,
                      width: (index == _currentPage) ? 30 : 10,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: (index == _currentPage) ? orange : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              widget.space.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.authentifiedUserId != null
                ? () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RatingAlertDialog(
                    spaceTitle: widget.space.title,
                    onRatingUpdate: widget.onRatingUpdate,
                    initialRating: widget.initialRating,
                    submit: widget.submit,
                  );
                },
              );
            }
                : null,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: widget.space.rating != null
                      ? Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: yellow,
                        size: 16,
                      ),
                      Text(
                        "${widget.space.rating}/5 ",
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "(${widget.space.numberOfRatings})",
                        style: const TextStyle(color: gray),
                      ),
                    ],
                  )
                      : const Text(
                    "Aucune note",
                    style: TextStyle(color: gray),
                  ),
                ),
                widget.authentifiedUserId != null
                    ? const Icon(
                  Icons.edit,
                  size: 20,
                )
                    : SizedBox(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              "A propos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(
              widget.space.description ?? '',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
