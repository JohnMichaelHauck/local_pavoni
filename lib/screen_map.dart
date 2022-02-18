import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:local_pavoni/firebase_cnp.dart';
import 'package:local_pavoni/world_cnp.dart';
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
        if (!firebaseChangeNotifier.isSignedIn) {
          return Container();
        }

        var myWorldState = worldChangeNotifier.state(
            firebaseChangeNotifier.country, firebaseChangeNotifier.state);
        var myLatLng = LatLng(myWorldState.latitude, myWorldState.longitude);
        var cameraPosition = CameraPosition(target: myLatLng, zoom: 6);

        return FutureBuilder<Set<Marker>>(
            future:
                generateMarkers(worldChangeNotifier, firebaseChangeNotifier),
            initialData: const <Marker>{},
            builder: (context, snapshot) => GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: cameraPosition,
                  markers: snapshot.data ?? const <Marker>{},
                ));
      },
    );
  }

  Future<Set<Marker>> generateMarkers(WorldChangeNotifier worldChangeNotifier,
      FirebaseChangeNotifier firebaseChangeNotifier) async {
    var markers = <Marker>{};
    for (var censusCountry in firebaseChangeNotifier.censusCountries) {
      for (var censusState in censusCountry.states) {
        var worldState =
            worldChangeNotifier.state(censusCountry.name, censusState.name);
        markers.add(Marker(
          anchor: const Offset(0, 0),
          markerId: MarkerId(censusCountry.name + " " + censusState.name),
          position: LatLng(worldState.latitude, worldState.longitude),
          icon: await stateCensusIcon(censusState.census),
        ));
      }
    }
    return markers;
  }

  Future<BitmapDescriptor> stateCensusIcon(int census) async {
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);

    var paint = Paint();
    paint.color = Colors.grey;
    canvas.drawRRect(
        RRect.fromLTRBR(0, 20, 60, 50, const Radius.circular(15)), paint);

    TextSpan span = TextSpan(
      style: const TextStyle(
          color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
      text: census.toString(),
    );

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    tp.layout(minWidth: 60, maxWidth: 60);
    tp.paint(canvas, const Offset(0, 20));

    var p = pictureRecorder.endRecording();

    var img = await p.toImage(60, 50);

    ByteData? pngBytes = await img.toByteData(format: ImageByteFormat.png);
    if (pngBytes != null) {
      var data = Uint8List.view(pngBytes.buffer);
      return BitmapDescriptor.fromBytes(data);
    }

    return BitmapDescriptor.defaultMarker;
  }
}
