import 'package:flutter/material.dart';
import 'package:hello_way_client/view_models/location_permission_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/routes.dart';

class CameraPermissionViewModel extends ChangeNotifier  {
  final LocationPermissionViewModel _locationPermissionViewModel =
  LocationPermissionViewModel();
  Future<PermissionStatus> checkCameraPermission(BuildContext context) async {
    // Check if camera permission is granted
    PermissionStatus status = await Permission.camera.status;
    if (!status.isGranted) {
      // Request camera permission
      status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {

        Navigator.pushNamed(context, cameraScreenRoute);
        return status;
      } else if (status == PermissionStatus.denied) {
        // Permission denied
      //  _showPermissionDeniedDialog(context);
        return status;
      } else if (status == PermissionStatus.permanentlyDenied) {
        // Permission permanently denied, take user to app settings
        // openAppSettings();
        return status;
      }
    } else {
      // Permission already granted
      Navigator.pushNamed(context, cameraScreenRoute);
      return status;
    }
    return status;
  }
}