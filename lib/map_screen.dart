import 'package:flutter/material.dart';
import 'package:local_pavoni/firebase.dart';
import 'package:local_pavoni/world.dart';
import 'package:provider/provider.dart';
import 'main.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
// https://medium.com/flutter-community/flutter-web-and-google-maps-f2489b483a1f
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: const MapBody(),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
    );
  }
}

class MapBody extends StatelessWidget {
  const MapBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorldChangeNotifier, FirebaseChangeNotifier>(
      builder: (context, worldChangeNotifier, firebaseChangeNotifier, child) {
        var state = worldChangeNotifier.state(
            firebaseChangeNotifier.country, firebaseChangeNotifier.state);
        var latlng = LatLng(state.latitude, state.longitude);
        var cameraPosition = CameraPosition(target: latlng, zoom: 6);
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: cameraPosition,
          //onMapCreated: (GoogleMapController controller) {},
        );
      },
    );
  }
}
