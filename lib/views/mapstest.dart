import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';



class MapsPage extends StatefulWidget {
  const MapsPage({super.key});



  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {

  List _data = [];
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior();
    _data =  const [
      Model('Café Resto Le 716', 36.841886, 10.271520),
      Model('Inner Karada', 33.305668, 44.427568),
      Model('Arasat AlHindiya', 33.294748, 44.428752),
      Model('Daoudi', 33.309746, 44.332999),
      Model('Baghdad International Airport', 33.249025, 44.248412)
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return   Scaffold(

      body: Center(
        child: SfMaps(
          layers: [
            MapTileLayer(
              initialZoomLevel: 9,
              initialFocalLatLng: const MapLatLng(36.861797, 10.056874),
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              initialMarkersCount: _data.length,
              markerBuilder: (BuildContext context, int index) {
                return MapMarker(
                  latitude: _data[index].latitude,
                  longitude: _data[index].longitude,
                  // iconColor: Colors.white,
                  // iconStrokeWidth: 2,
                  // iconStrokeColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.location_history),
                    onPressed: (){
                      print('Clicked! : ${_data[index].name}');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                          content: Text('Clicked! : ${_data[index].name}')));
                    },
                  ),
                );
              },
              zoomPanBehavior: _zoomPanBehavior,
            ),
          ],
        ),
      ),
    );
  }
}


class Model {
  const Model(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}