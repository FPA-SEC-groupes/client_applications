import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hello_way_client/models/space.dart';
import 'package:hello_way_client/view_models/RestrictionsViewModel.dart';
import 'package:hello_way_client/views/space.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/button.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../shimmer/card_menu_shimmer.dart';
import '../utils/const.dart';
import '../utils/routes.dart';
import '../utils/secure_storage.dart';
import '../view_models/home_view_model.dart';
import '../view_models/location_permission_view_model.dart';
import '../widgets/modal_bottom_sheet.dart';
import '../widgets/space_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_provider.dart';
// import 'mapstest.dart'; // Make sure you have a theme provider

class Home extends StatefulWidget {
  final Function(int) changePageIndex;

  Home({required this.changePageIndex});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationPermissionViewModel _locationPermissionViewModel = LocationPermissionViewModel();
  late HomeViewModel _homeViewModel;
  final SecureStorage secureStorage = SecureStorage();
  late RestrictionsViewModel _restrictionsViewModel;
  double _distance = 0.0;
  bool _switchValue = false;
  List<String> selectedCategories = [];
  bool _isSearching = false;
  String _searchQuery = '';
  late int numberOfRestriction = 0;
  bool authentifiedUser=false;
  Future<void> verifyAuthentication() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    int? id = int.tryParse(userId!);
    if(id!=null){
      setState(() {
        authentifiedUser=true;
      });
    }

    _restrictionsViewModel.getNumberOfRestrictionsByUserId(id!).then((nb) {
      setState(() {
        numberOfRestriction=nb;
      });
    }).catchError((error) {
      // Handle signup error
    });
    // String? numberOfRestrictionsString = await secureStorage.readData(numberOfRestrictions);
    // if (numberOfRestrictionsString != null) {
    //   int? numberOfRestriction1 = int.tryParse(numberOfRestrictionsString);
    //   setState(() {
    //     authentifiedUser = userId != null;
    //     numberOfRestriction = numberOfRestriction1 ?? 0;
    //     print("nbbbbbbbbbbbbbbbbbbbb       $numberOfRestriction");
    //   });
    // } else {
    //   setState(() {
    //     authentifiedUser = userId != null;
    //     numberOfRestriction = 0; // Default value if the string is null
    //   });
    //
    // }

  }
  @override
  void initState() {
    _homeViewModel = HomeViewModel(context);
    _restrictionsViewModel = RestrictionsViewModel(context);
    super.initState();
    _fetchSpaces();
    checkLocationPermission();
    verifyAuthentication();

  }

  Future<List<Space>> _fetchSpaces() async {
    final switchValue = await secureStorage.readData(switchValueKey);
    final distance = await secureStorage.readData(distanceKey);
    List<Space> fetchedSpaces = [];
    if (await checkLocationPermission() && switchValue == 'true') {
      await _locationPermissionViewModel.getUpdatedLocation().then((position) async {
        fetchedSpaces = await _homeViewModel.getNearestSpacesByDistance(position.latitude, position.longitude, double.parse(distance!));
      }).catchError((error) {
        print(error);
      });
      return fetchedSpaces;
    } else {
      return await _homeViewModel.getSpaces();
    }
  }

  Future<bool> checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    print(status);
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);

    return Scaffold(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orange,  // Set to always be orange
          title: _isSearching
              ? TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.search,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
            ),
          )
              : Text(AppLocalizations.of(context)!.home, style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close_rounded : Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _searchQuery = '';
                });
              },
            ),
            IconButton(
                icon: SvgPicture.asset(
                  'assets/images/filter-icon.svg',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Placeholder for filter action
                }
            ),
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: Icon(Icons.map_outlined, color: orange),
                onPressed: () async {
                  await _locationPermissionViewModel.checkLocationPermission(context).then((status) async {
                    if(status==PermissionStatus.granted){
                      widget.changePageIndex(1);
                    }


                  }).catchError((error) {
                    // Handle signup error
                  });

                },
              ),
            )
          ],
        ),
      body: networkStatus == NetworkStatus.Online
          ? FutureBuilder(
        future: _fetchSpaces(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 3,
              itemBuilder: (context, groupIndex) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5,
                      ),
                      child: Shimmer.fromColors(
                        baseColor: gray.withOpacity(0.5),
                        highlightColor: Colors.white,
                        child: Container(
                          height: 15,
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardMenuShimmer(),
                            SizedBox(
                              width: 10,
                            ),
                            CardMenuShimmer(),
                          ]),
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.hasError.toString()),
            );
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(
              child: Text('No data found'),
            );
          } else {
            final List<Space> spaces;
            if (_searchQuery.isEmpty) {
              spaces = snapshot.data!;
            } else {
              spaces = (snapshot.data! as List<Space>)
                  .where((space) =>space.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();
            }
            return ListView.separated(
              itemCount: listSpaceCategories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = listSpaceCategories[index];
                final spacesByCategory = spaces
                    .where((space) => space.category == category)
                    .toList();

                return spacesByCategory.length > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5,
                            ),
                            child: Text(
                              category,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: spacesByCategory.length,
                              itemBuilder: (context, index) {
                                final space = spacesByCategory[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                    bottom: 10,
                                  ),
                                  child: GestureDetector(
                                    child: SpaceCard(space: space),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailsSpace(space: space,nb:numberOfRestriction, authentifiedUser:authentifiedUser ,
                                          ),
                                        ),
                                      );

                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox();
              },
            );
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
      )
    );
  }
}
