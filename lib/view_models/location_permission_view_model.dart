import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
typedef PositionCallBack =Function(Position position);
class LocationPermissionViewModel  {

  late StreamSubscription<Position> _postionStream;


  Future<PermissionStatus> checkLocationPermission(BuildContext context) async {
    // Check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print('Location services are not enabled');
    }

    // Check if location permission is granted
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      // Request location permission
      status = await Permission.locationWhenInUse.request();
      if (status == PermissionStatus.granted) {
        // Permission granted
        print(isLocationEnabled);
        return status;
      } else if (status == PermissionStatus.denied) {
        // Permission denied
        _showPermissionDeniedDialog(context);
        print(isLocationEnabled);
        return status;
      } else if (status == PermissionStatus.permanentlyDenied) {
        // Permission permanently denied, take user to app settings
        _showPermissionDeniedDialog(context);
        // openAppSettings();
        return status;
      }
    } else {
      // Permission already granted
      return status;
    }
    return status;
  }

  Future<Position> getUpdatedLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true
    );

    return position;
  }
  Future<Position> getCureentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return position;
  }

  Future<void>startPositionStream(Function(Position position) callback) async {

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,

    );
    _postionStream = Geolocator.getPositionStream(locationSettings: locationSettings ).listen(callback);
  }

  Future<void> stopPositionStream() async {
    await _postionStream.cancel();
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Location permission is required to use this feature.'),
          actions: <Widget>[
            MaterialButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: Text('SETTINGS'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
