import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:hello_way_client/utils/secure_storage.dart';
import 'package:hello_way_client/views/add_reservation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/space.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../widgets/app_bar.dart';
import '../models/theme_provider.dart';

class DetailsSpace extends StatefulWidget {
  final Space space;
  const DetailsSpace({super.key, required this.space});

  @override
  _DetailsSpaceState createState() => _DetailsSpaceState();
}

class _DetailsSpaceState extends State<DetailsSpace> {
  final PageController _pageController = PageController();
  final SecureStorage secureStorage = SecureStorage();
  int _currentPage = 0;
  List<Widget> _pages = [];
  Timer? _timer;
  bool authentifiedUser = false;

  Future<void> verifyAuthentication() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    setState(() {
      authentifiedUser = userId != null;
    });
  }

  @override
  void initState() {
    verifyAuthentication();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pages = widget.space.images!.isEmpty
            ? [
          FittedBox(
            child: Icon(Icons.image_outlined, color: gray),
          )
        ]
            : List.generate(
          widget.space.images!.length,
              (index) => Container(
            height: 50,
            child: ClipRRect(
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.memory(
                  base64.decode(widget.space.images![index].data),
                ),
              ),
            ),
          ),
        );
      });
      startTimer();
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (_currentPage < _pages.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void stopTimer() {
    _timer?.cancel();
  }

  launchCaller(String phoneNumber) async {
    final PermissionStatus status = await Permission.phone.request();
    if (status == PermissionStatus.granted) {
      final uri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Impossible de lancer l\'appel : $phoneNumber';
      }
    } else {
      throw 'La permission d\'accéder au téléphone n\'a pas été accordée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: Toolbar(
        title: widget.space.title,
      ),
      body: networkStatus == NetworkStatus.Online
          ? Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: screenHeight / 2.5,
                    child: PageView(
                      controller: _pageController,
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
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 20, top: 10, bottom: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, spaceLocationRoute, arguments: widget.space);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_sharp,
                        color: orange,
                        size: 25.0,
                      ),
                      Text(
                        AppLocalizations.of(context)!.location,
                        style: const TextStyle(fontSize: 18, color: orange),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text(
                  AppLocalizations.of(context)!.about,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  widget.space.description,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: orange,
                      ),
                      child: MaterialButton(
                        height: 50,
                        onPressed: () {
                          authentifiedUser
                              ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReservation(space: widget.space),
                            ),
                          )
                              : Navigator.pushNamed(context, loginRoute).then((user) async {
                            await verifyAuthentication();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReservation(space: widget.space),
                              ),
                            ).then((user) async {
                              await verifyAuthentication();
                            }).catchError((error) {
                              print(error);
                            });
                          }).catchError((error) {
                            print(error);
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.book,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    onTap: () {
                      launchCaller("tel:${widget.space.phoneNumber}");
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.green,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 30.0,
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
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
