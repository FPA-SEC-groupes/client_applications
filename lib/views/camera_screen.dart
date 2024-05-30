import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/basket_view_model.dart';
import '../view_models/location_permission_view_model.dart';
import '../view_models/qr_code_view_model.dart';
import '../widgets/alert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late final BasketViewModel _basketViewModel;
  final SecureStorage secureStorage = SecureStorage();
  late final QrCodeViewModel _qrCodeViewModel ;
  final LocationPermissionViewModel _locationPermissionViewModel =
  LocationPermissionViewModel();
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flashState = false;
  late AnimationController animationController;
  late Animation<double> animation;

  Future<Position>getPosition() async {
    Position position=await _locationPermissionViewModel.getUpdatedLocation();
    return position;
  }





  @override
  void initState() {
    _basketViewModel = BasketViewModel(context);
    _qrCodeViewModel = QrCodeViewModel(context);
    getPosition();
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(animationController);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        appBar: AppBar(
          title:  Text(AppLocalizations.of(context)!.scanQRCode),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () async {
            await controller?.toggleFlash();
            setState(() {
              flashState = !flashState;
            });
          },
          child:
          Icon(flashState ? Icons.flash_on_rounded : Icons.flash_off_rounded),
        ),
        body:networkStatus == NetworkStatus.Online
            ?  Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.orange,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
              ),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
            ),
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0.0,
                      animation.value * (MediaQuery.of(context).size.height / 6),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 2,
                      color: Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ],
        ):Center(
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
                SizedBox(height: 10,),
                MaterialButton(
                  color: orange,
                  height: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed:(){
                    setState(() {

                    });
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
        )
    );
  }

  Future<void> _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool p) async {
    if (p) {
      // Permission is granted, open the camera
      try {
        // ctrl.resumeCamera();
        setState(() {
          animationController.repeat(reverse: true);
        });

        // Start the camera preview
      } catch (e) {
        print('Error opening camera: $e');
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) async {
      if (result == null &&
          scanData.format.toString() == 'BarcodeFormat.qrcode') {
        setState(() {
          result = scanData;
          print(result!.code.toString());
        });
        final userId = await secureStorage.readData(authentifiedUserId);

        // await _locationPermissionViewModel.getUpdatedLocation().then((position) {
        if (userId != null) {
          _qrCodeViewModel
              .setUserOnTheTable(
            result!.code.toString(),
            // position,2*position.accuracy
          )
              .then((data) async {

            if (data == false) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return  CustomAlertDialog(
                      title: AppLocalizations.of(context)!.positionTooFar,
                      content: AppLocalizations.of(context)!.positionTooFarMessage);
                },
              );
            } else {
              print(data);

              await secureStorage.writeData(
                  tableIdKey, data['tableId']);
              await secureStorage.writeData(
                  sessionIdKey, data['sessionId']);
              await secureStorage.writeData(
                  spaceIdKey,data['spaceId']);

              _basketViewModel
                  .getLatestBasketByIdTable(
                  data['tableId'].toString())
                  .then((_) async {

                Navigator.pushReplacementNamed(context, menuRoute);
              })
                  .catchError((error) {
                print(error);
              });
            }
          }).catchError((error) {});
        } else {
          _qrCodeViewModel
              .setGuestOnTheTable(result!.code.toString(),
            // position,1.5*position.accuracy
          ).then((response) async {

            print(response);
            if (response ==false) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return  CustomAlertDialog(
                      title: AppLocalizations.of(context)!.positionTooFar,
                      content: AppLocalizations.of(context)!.positionTooFarMessage);
                },
              );

            } else {
              Fluttertoast.showToast(
                msg: "data2: ${response.toString()}",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[800],
                textColor: Colors.white,
              );
              final spaceId = response.lastname;
              final tableId = response.username.substring(5);
              await secureStorage.writeData(spaceIdKey,spaceId!);
              await secureStorage.writeData(userIdKey,response.id!.toString());
              await secureStorage.writeData(sessionIdKey, response.sessionId!);
              await secureStorage.writeData(tableIdKey,tableId);
              print(tableId);
              _basketViewModel.getLatestBasketByIdTable(tableId).then((_) async {


                Navigator.pushReplacementNamed(context, menuRoute);
              })
                  .catchError((error) {
                print(error);
              });
            }
          }).catchError((error) {
            print(error);
          });
        }
        // }).catchError((error) {
        //   print(error);
        // });
      }
    });
  }

  @override
  void dispose() {

    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }
}
