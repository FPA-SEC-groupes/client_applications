import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../models/user.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/basket_view_model.dart';
import '../view_models/camera_permission_view_model.dart';
import '../view_models/location_permission_view_model.dart';
import '../view_models/qr_code_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/alert_dialog.dart';

class ScanQrCode extends StatefulWidget {
  final PermissionStatus? status;
  const ScanQrCode({super.key, this.status});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final CameraPermissionViewModel _cameraPermissionViewModel =
  CameraPermissionViewModel();
  late final QrCodeViewModel _qrCodeViewModel;
  final SecureStorage secureStorage = SecureStorage();

  late final BasketViewModel _basketViewModel;
  final LocationPermissionViewModel _locationPermissionViewModel =
  LocationPermissionViewModel();
  Position? _userPosition;

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
      print("Longitude:: ${position.longitude}");
      print("Latitude:: ${position.latitude}");
    });
  }

  @override
  void initState() {
    super.initState();
    _qrCodeViewModel = QrCodeViewModel(context);
    _basketViewModel = BasketViewModel(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.status == PermissionStatus.granted) {
        _locationPermissionViewModel.startPositionStream(_handlePositionStream);
      }
      await _requestWifiPermission();
    });
  }

  Future<void> _requestWifiPermission() async {
    // Request location and WiFi permissions
    var locationPermission = await Permission.location.request();
    var wifiPermission = await Permission.locationWhenInUse.request();

    if (locationPermission.isGranted && wifiPermission.isGranted) {
      bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isWifiEnabled) {
        await WiFiForIoTPlugin.setEnabled(true);
      }
    } else {
      // Show alert if permission is denied
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: AppLocalizations.of(context)!.positionTooFar,
          content: AppLocalizations.of(context)!.positionTooFarMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      body: networkStatus == NetworkStatus.Online
          ? widget.status == PermissionStatus.granted
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: orange,
              shape: const CircleBorder(),
              onPressed: () async {
                _cameraPermissionViewModel
                    .checkCameraPermission(context)
                    .then((status) async {
                  print(status);
                }).catchError((error) {
                  print(error);
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 150,
              color: gray,
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 24),
                children: [
                  TextSpan(
                      text: AppLocalizations.of(context)!
                          .locationAccessRequired,
                      style: const TextStyle(color: gray)),
                  TextSpan(
                    text: AppLocalizations.of(context)!.retry,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: orange),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle tap on 'Retry'
                        openAppSettings();
                      },
                  ),
                ],
              ),
            ),
          ],
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
              const SizedBox(
                height: 10,
              ),
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
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
