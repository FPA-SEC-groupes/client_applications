import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_way_client/utils/secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/space.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../view_models/home_view_model.dart';
import '../view_models/location_permission_view_model.dart';
import '../widgets/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SpacesMapScreen extends StatefulWidget {
  final Function(int) changePageIndex;

  SpacesMapScreen({required this.changePageIndex, Key? key}) : super(key: key);

  @override
  State<SpacesMapScreen> createState() => SpacesMapScreenState();
}

class SpacesMapScreenState extends State<SpacesMapScreen> {
  final SecureStorage secureStorage = SecureStorage();
  final LocationPermissionViewModel _locationPermissionViewModel =
      LocationPermissionViewModel();
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late HomeViewModel _homeViewModel;
  double _distance = 0.0;
  bool _switchValue = false;
  List<String> selectedCategories = [];
  LatLng? latLng;



  Future<void> getUserLocation() async {
    await _locationPermissionViewModel.getCureentLocation().then((position) {

      setState(() {
        latLng = LatLng(position.latitude,position.longitude);
      });

    }).catchError((error) {
      print(error);
    });
  }




  @override
  void initState() {
    _homeViewModel = HomeViewModel(context);
    getUserLocation();
    checkLocationPermission();

    _fetchSpaces();
    super.initState();
  }



  Future<bool> checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    print(status);
    return status.isGranted;
  }

  Future<List<Space>> _fetchSpaces() async {
    final switchValue = await secureStorage.readData(switchValueKey);
    final distance = await secureStorage.readData(distanceKey);

    List<Space> spaceList = [];

    if (await checkLocationPermission() && switchValue == 'true') {
      try {
        final position =
            await _locationPermissionViewModel.getUpdatedLocation();
        spaceList = await _homeViewModel.getNearestSpacesByDistance(
          position.latitude,
          position.longitude,
          double.parse(distance!),
        );
      } catch (error) {
        print(error);
        // Handle errors gracefully if needed
      }
    } else {
      spaceList = await _homeViewModel.getSpaces();
    }

    // Clear previous markers and add new ones
   _markers.clear();
    for (var space in spaceList) {
      if (listSpaceCategories.contains(space.category)) {
        LatLng position = LatLng(
          double.parse(space.latitude),
          double.parse(space.longitude),
        );

        Marker marker = Marker(
          markerId: MarkerId(space.id.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: space.title,
            // Add more properties if needed, like snippet for additional info
          ),
        );
        _markers.add(marker);
      }
    }

    return spaceList;
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Carte'),
          actions: [
            IconButton(
                icon: SvgPicture.asset(
                  'assets/images/filter-icon.svg',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
                onPressed: () async {
                  String? userId =
                      await secureStorage.readData(authentifiedUserId);
                  if (userId != null) {
                    List<String> retrievedList = [];
                    final selectedCategoriesListAsString =
                        await secureStorage.readData(selectedCategoriesKey);
                    if (selectedCategoriesListAsString != null) {
                      retrievedList = selectedCategoriesListAsString.split(',');
                    }

                    if (retrievedList.isNotEmpty && selectedCategories.isEmpty) {
                      setState(() {
                        selectedCategories = retrievedList;
                      });
                    }
                    final distance = await secureStorage.readData(distanceKey);
                    final switchValue =
                        await secureStorage.readData(switchValueKey);

                    if (distance != null && await checkLocationPermission()) {
                      _distance = double.parse(distance);
                    }

                    if (await checkLocationPermission() &&
                        switchValue == 'true') {
                      _switchValue = true;
                    } else {
                      _switchValue = false;
                    }
                    print(_switchValue);
                    if (mounted) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return ModalBottomSheet(
                            distance: _distance,
                            switchValue: _switchValue,
                            selectedCategories: selectedCategories,
                            onChanged: (value) {
                              setState(() {
                                _distance = value;
                              });
                            },
                            reset: () {
                              setState(() {
                                selectedCategories = [];
                              });
                            },
                            submit: () async {
                              print(_distance);
                              print(_switchValue);
                              print(selectedCategories);
                              if(selectedCategories.isNotEmpty){
                              String listAsString = selectedCategories.join(',');
                              await secureStorage.writeData(selectedCategoriesKey, listAsString);
                              }
                              await secureStorage.writeData(switchValueKey, _switchValue.toString());
                              await secureStorage.writeData(
                                  distanceKey, _distance.toString());
                              setState(() {
                                if (selectedCategories.isNotEmpty) {
                                  listSpaceCategories = selectedCategories;
                                } else {
                                  listSpaceCategories = [
                                    "Cafes",
                                    "Restaurant",
                                    "Bar"
                                  ];
                                  print("im here");
                                  print(listSpaceCategories);
                                }
                                _fetchSpaces();
                              });


                              if (mounted) {
                                Navigator.of(context).pop();
                              }

                              // Close the bottom sheet
                            },
                            onSwitchUpdated: (switchValue) {
                              // Update the position in the parent widget with the obtained position
                              setState(() {
                                _switchValue = switchValue;
                              });
                            },
                          );
                        },
                      );
                    }
                  } else {
                    Navigator.pushNamed(context, loginRoute, arguments: 0);
                  }
                }),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white, // Background color for the circular container
              ),
              child: IconButton(
                icon: const Icon(Icons.list, color: orange),
                onPressed: () {
                  widget.changePageIndex(0);
                },
              ),
            )
          ],
        ),
        body: networkStatus == NetworkStatus.Online
            ? FutureBuilder<List<Space>>(
          future: _fetchSpaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading spaces'),
              );
            } else {
              // Build GoogleMap with markers after fetching spaces
              return latLng != null
                  ? GoogleMap(
                onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: latLng!,
                        zoom: 15.0,
                      ),
                      padding: EdgeInsets.only(bottom: 70.0),
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                    )
                  : const Center(child: CircularProgressIndicator());
            }
          },
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
        ),);
  }
}
