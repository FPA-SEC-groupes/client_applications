import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:hello_way_client/views/home.dart';
import 'package:hello_way_client/views/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hello_way_client/views/list_notifications.dart';
import 'package:hello_way_client/view_models/notifications_view_model.dart';
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
  final int? index;
  const BottomNavigationBarWithFAB({this.index}) ;

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
    int unseenNotifications = 0;
    StreamSubscription<void>? _streamSubscription;
    late NotificationViewModel _notificationViewModel;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? nbNotifications;
  Future<void> getNbNewNotiofications() async {
    const interval = Duration(seconds: 15);

    _streamSubscription=Stream.periodic(interval).listen((_) async {
      var _nbNotifications = await secureStorage.readData(nbNewNotifications);

      setState(() {
        nbNotifications = _nbNotifications;
      });
    });
  }
  /// Fetch unseen notifications count
  Future<void> fetchUnseenNotifications() async {
    try {
      String? userId = await secureStorage.readData(authentifiedUserId);
      if (userId != null) {
        List notifications = await _notificationViewModel.fetchNewNotificationsForUser(userId);
        int newUnseenCount = notifications.length;

        if (mounted) {
          setState(() {
            unseenNotifications = newUnseenCount;
          });
        }
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  /// Listen for Firebase Push Notifications
  void setupFirebaseNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("New Notification: ${message.notification?.title}");

      // Refresh unseen notifications count
      fetchUnseenNotifications();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("Notification Clicked: ${message.notification?.title}");

      // When clicked, mark notifications as read
      await _notificationViewModel.markAllNotificationsAsSeen();
      setState(() {
        unseenNotifications = 0;
      });
    });
  }
  @override
  void initState() {

    // TODO: implement initState
    _notificationViewModel = NotificationViewModel(context);
    getNbNewNotiofications();
    _currentIndex = widget.index ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var index = ModalRoute.of(context)!.settings.arguments as int?;
      if(index!=null){
          _currentIndex=widget.index!;
          _onItemTapped(_currentIndex);
      }
    });
    fetchUnseenNotifications();

    // Listen for Firebase Push Notifications
    setupFirebaseNotifications();

    // Periodic check every 15 seconds
    _streamSubscription = Stream.periodic(const Duration(seconds: 15)).listen((_) async {
      await fetchUnseenNotifications();
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
    return   WillPopScope(
        onWillPop: () async {
          return false;
          },
        child:Scaffold(
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
                    _updateLocation(status);
                    _onItemTapped(2);
                  }).catchError((error) {
                  });
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
                      if (unseenNotifications > 0)
                        Positioned(
                          right: -1,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                            child: Text(unseenNotifications.toString(), style: const TextStyle(color: Colors.white, fontSize: 9)),
                          ),
                        ),
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
                    await _notificationViewModel.markAllNotificationsAsSeen();
                    setState(() {
                      unseenNotifications = 0;
                    });
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
                      Navigator.pushNamed(context, loginRoute, arguments: {'previousPage': 'notification', 'index': 1},);
                    }
                  },
                ),
                const SizedBox(width: 40,),
                IconButton(
                  icon: Icon(Icons.perm_identity_sharp,color:_currentIndex == 3 ?orange : Colors.grey),
                  onPressed: () async {
                    String? userId = await secureStorage.readData(authentifiedUserId);
                    if (userId != null) {
                      _onItemTapped(3);
                      setState(() {
                        _interfaces[3] = MyAccount(); // update the widget with the new values
                      });
                    } else {
                      Navigator.pushNamed(context, loginRoute,arguments: {'previousPage': 'compte', 'index': 3});
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
        )
      );
    }
  }

