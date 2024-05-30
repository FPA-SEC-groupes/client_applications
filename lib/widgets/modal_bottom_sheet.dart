import 'package:flutter/material.dart';
import 'package:hello_way_client/view_models/location_permission_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../res/app_colors.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import 'button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ModalBottomSheet extends StatefulWidget {
  double distance;
  bool switchValue;
  final void Function()? reset;
  final void Function(bool) onSwitchUpdated;
   List<String> selectedCategories;


  final void Function(dynamic)? onChanged;
  final void Function()? submit;
  ModalBottomSheet(
      {required this.distance,
      required this.switchValue,
      required this.selectedCategories,
      this.onChanged,
      Key? key,
      this.submit,
      required this.onSwitchUpdated, this.reset})
      : super(key: key);
  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  final LocationPermissionViewModel _locationPermissionViewModel =
      LocationPermissionViewModel();
  final SecureStorage secureStorage = SecureStorage();
  List<String> categories = ["Cafes", "Restaurant", "Bar"];
  bool?  _reset;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQueryData.fromView(WidgetsBinding.instance.window),
        child: SafeArea(
          child: Scaffold(
              body: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: const Icon(Icons.close_rounded,
                                color: Colors.black),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            "Filter",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            child: Text(
                              "Reset all",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: orange),
                            ),
                            onTap:() async {

                              await secureStorage.deleteData(selectedCategoriesKey);
                              await secureStorage.deleteData(switchValueKey);
                              await secureStorage.deleteData(distanceKey);
                              setState(() {
                                widget.switchValue = false;
                                widget.onSwitchUpdated(false);
                                widget.distance=0;
                                widget.selectedCategories=[];
                                listSpaceCategories=["Cafes","Restaurant","Bar"];
                              });
                              widget.reset?.call();

                            },
                          )
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Distance',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Switch(
                          activeColor: orange,
                          value: widget.switchValue,
                          onChanged: (bool value) async {
                            // Call the provided onChanged callback to update the switch value

                           await _locationPermissionViewModel
                                .checkLocationPermission(context)
                                .then((status) async {
                              if (status == PermissionStatus.granted) {
                                setState(() {
                                  widget.switchValue = value;
                                  widget.onSwitchUpdated(value);
                                  if (widget.switchValue == false) {
                                    widget.distance = 0;
                                  }
                                });
                              } else if ((status ==
                                  PermissionStatus.permanentlyDenied)) {
                                _showPermissionDeniedDialog(context);
                                setState(() {
                                  widget.switchValue = false;
                                  widget.onSwitchUpdated(false);
                                  widget.distance = 0;
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: widget.switchValue,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              "Seuls les espaces situés à l'intérieur du rayon spécifié s'affichent.",
                              style: TextStyle(fontSize: 16, color: gray),
                            ),
                          ),
                          SfSlider(
                            min: 0.0,
                            max: 100.0,
                            value: widget.switchValue ? widget.distance : 0,
                            enableTooltip: true,
                            minorTicksPerInterval: 1,
                            onChanged: (dynamic value) {
                              // Call the provided onChanged callback to update the switch value

                              setState(() {
                                widget.onChanged?.call(value);
                                widget.distance = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Categories',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Filtrer les résultats en sélectionnant les catégories que vous souhaitez afficher",
                      style: TextStyle(fontSize: 16, color: gray),
                    ),
                  ),
                  CheckboxListTile(
                    activeColor: orange,
                    title: Text("Cafes"),
                    value: widget.selectedCategories.contains("Cafes"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          widget.selectedCategories.add("Cafes");
                        } else {
                          widget.selectedCategories.remove("Cafes");
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    activeColor: orange,
                    title: Text("Restaurant"),
                    value: widget.selectedCategories.contains("Restaurant"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          widget.selectedCategories.add("Restaurant");
                        } else {
                          widget.selectedCategories.remove("Restaurant");
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    activeColor: orange,
                    title: Text("Bar"),
                    value: widget.selectedCategories.contains("Bar"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          widget.selectedCategories.add("Bar");
                        } else {
                          widget.selectedCategories.remove("Bar");
                        }
                      });
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Button(text: "Appliquer", onPressed: widget.submit),
                ),
              )
            ],
          )),
        ));
  }
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
