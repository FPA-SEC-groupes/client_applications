import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way_client/res/strings.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/user.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/my_account_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_provider.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  late MyAccountViewModel _myAccountViewModel;
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    _myAccountViewModel = MyAccountViewModel(context);
    getUserById();
    super.initState();
  }

  Future<User?> getUserById() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    print("idddddddddddddddddddddddddddddddd"+userId.toString());

    if (userId != null) {
      User user = await _myAccountViewModel.fetchUserById();
      return user;
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
          AppLocalizations.of(context)!.myAccount,
          style: const TextStyle(color: Colors.white),
        ),

      ),
      body: networkStatus == NetworkStatus.Online
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<User?>(
                future: getUserById(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: Shimmer.fromColors(
                        baseColor: gray.withOpacity(0.5),
                        highlightColor: Colors.white,
                        child: const CircleAvatar(
                          radius: 20.0,
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: gray.withOpacity(0.5),
                        highlightColor: Colors.white,
                        child: Container(
                          height: 15,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, profileRoute);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No data found'),
                    );
                  } else {
                    final user = snapshot.data!;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      leading: CircleAvatar(
                        backgroundColor: gray,
                        child: ClipOval(
                          child: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: user.image == null
                                ? const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                            )
                                : Image.memory(
                              base64.decode(user.image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(user.username, style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pushNamed(context, profileRoute).then((_) {
                          setState(() {
                            getUserById();
                          });
                        });
                      },
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                visualDensity: const VisualDensity(vertical: 0.0),
                dense: true,
                title: Text(
                  AppLocalizations.of(context)!.myOrders,
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pushNamed(context, listCommandsRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                visualDensity: const VisualDensity(vertical: 0.0),
                dense: true,
                title: Text(
                  AppLocalizations.of(context)!.myReservations,
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pushNamed(context, listReservationsRoute);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                visualDensity: const VisualDensity(vertical: 0.0),
                dense: true,
                title: Text(
                  AppLocalizations.of(context)!.disconnection,
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  _myAccountViewModel.logout().then((_) {
                    secureStorage.deleteAll();
                    Navigator.pushNamed(context, bottomNavigationWithFABRoute);
                  }).catchError((error) {
                    print(error);
                  });
                },
              ),
            ],
          ),
        ),
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
