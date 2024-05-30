import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:hello_way_client/views/home.dart';

import 'package:hello_way_client/views/my_account.dart';
import 'package:hello_way_client/views/scan_qr_code.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/location_permission_view_model.dart';
import '../views/list_notifications.dart';
import '../views/settings.dart';
import '../views/test.dart';

class BottomNavigationBarWithFAB extends StatefulWidget {
  const BottomNavigationBarWithFAB({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarWithFAB> createState() =>
      _BottomNavigationBarWithFABState();
}

class _BottomNavigationBarWithFABState
    extends State<BottomNavigationBarWithFAB> {
  final SecureStorage secureStorage = SecureStorage();
  final LocationPermissionViewModel _locationPermissionViewModel = LocationPermissionViewModel();
  int _currentIndex = 0;
  PermissionStatus? _status;
   final List<Widget> _interfaces =  [Test(),ListNotifications(),ScanQrCode(),MyAccount(),Settings()];

  String? nbNotifications;
  StreamSubscription<void>? _streamSubscription;
  Future<void> getNbNewNotiofications() async {
    const interval = Duration(seconds: 15);

    _streamSubscription=Stream.periodic(interval).listen((_) async {
      var _nbNotifications = await secureStorage.readData(nbNewNotifications);

      setState(() {
        nbNotifications = _nbNotifications;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getNbNewNotiofications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var index = ModalRoute.of(context)!.settings.arguments as int?;
      if(index!=null){


          _currentIndex=index;
          _onItemTapped(_currentIndex);


      }
    });



    super.initState();
  }


  @override
  void dispose() {
    _streamSubscription!.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  void _updateLocation(PermissionStatus status) { // update the state and rebuild the widget tree
    setState(() {
      _status = status;
      _interfaces[2] = ScanQrCode(status: _status,); // update the widget with the new values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
      body: Center(
        child: IndexedStack(
          index: _currentIndex,
          children: _interfaces,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:

      SizedBox(

        height: 45.0,
        width: 45.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: orange,
            onPressed: () async {

              await _locationPermissionViewModel.checkLocationPermission(context).then((status) async {
                // get the current location data
                // update the state
                _updateLocation(status);
                _onItemTapped(2);

              }).catchError((error) {
                // Handle signup error
              });
             // Navigator.pushNamed(context, menuRoute);
            },
            elevation: 0,
            child: const Icon(Icons.qr_code_rounded,size: 30,),
          ),
        ),),
      bottomNavigationBar: BottomAppBar(

        clipBehavior: Clip.antiAlias,

        notchMargin: 5,
          shape: const CircularNotchedRectangle(


          ),


            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home_outlined,color:_currentIndex == 0 ?orange : Colors.grey),
                  onPressed: () {
                    _onItemTapped(0);
                  },
                ),
                IconButton(
                  icon:
                  Stack(
                    children: [
                      Icon(Icons.notifications_none_rounded,color:_currentIndex == 1 ?orange : Colors.grey),
                      nbNotifications != null && nbNotifications!="0"
                          ? Positioned(
                          right: -1,
                          top: 2,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.brightness_1,
                                color: Colors.red,
                                size: 14,
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    nbNotifications.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ))
                          : SizedBox(),
                    ],
                  ),
                  onPressed: () async {
                    String? userId = await secureStorage.readData(authentifiedUserId);
                    if (userId != null) {
                      print(userId);
                      _onItemTapped(1);
                      setState(() {
                        _interfaces[1] = ListNotifications(); // update the widget with the new values
                      });
                      await secureStorage.deleteData(nbNewNotifications);
                      setState(() {
                        nbNotifications=null;
                      });
                    } else {
                      Navigator.pushNamed(context, loginRoute,arguments: 1);
                    }
                  },
                ),

               const SizedBox(width: 40,),
                IconButton(
                  icon: Icon(Icons.perm_identity_sharp,color:_currentIndex == 3 ?orange : Colors.grey),
                  onPressed: () async {
                    String? userId = await secureStorage.readData(authentifiedUserId);
                    print(userId);
                    if (userId != null) {
                      _onItemTapped(3);
                      setState(() {
                          _interfaces[3] = MyAccount(); // update the widget with the new values
                      });

                    } else {
                      Navigator.pushNamed(context, loginRoute,arguments: 3);
                    }

                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined,color:_currentIndex == 4 ?orange : Colors.grey),
                  onPressed: () {
                    _onItemTapped(4);
                  },
                ),
              ],
            ),
          )
    );
  }
}
