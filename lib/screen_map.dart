import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:local_pavoni/cn_firebase.dart';
import 'package:local_pavoni/cn_world.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:flutter/foundation.dart';

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
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    var markers = <Marker>{};
    for (var censusCountry in firebaseChangeNotifier.censusCountries) {
      for (var censusState in censusCountry.states) {
        var worldState =
            worldChangeNotifier.state(censusCountry.name, censusState.name);
        markers.add(Marker(
          anchor: const Offset(0, 0),
          markerId: MarkerId(censusCountry.name + " " + censusState.name),
          position: LatLng(worldState.latitude, worldState.longitude),
          icon: await stateCensusIcon(
              censusState.census, isWebMobile ? 0.2 : 1), // isWebMobile hack
        ));
      }
    }
    return markers;
  }

  Future<BitmapDescriptor> stateCensusIcon(int census, double scale) async {
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    var width = 60 * scale;
    var height = 50 * scale;
    var fontSize = 25 * scale;

    TextSpan textSpan = TextSpan(
      style: TextStyle(
          color: Colors.black, fontSize: fontSize, fontWeight: FontWeight.bold),
      text: census.toString(),
    );

    TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    textPainter.layout(minWidth: width, maxWidth: width);

    var paint = Paint();
    paint.color = Colors.grey;
    canvas.drawRRect(
        RRect.fromLTRBR(0, height - textPainter.height, width, height,
            Radius.circular(height / 4)),
        paint);

    textPainter.paint(canvas, Offset(0, height - textPainter.height));

    var picture = pictureRecorder.endRecording();

    var image = await picture.toImage(width.ceil(), height.ceil());

    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      var data = Uint8List.view(byteData.buffer);
      return BitmapDescriptor.fromBytes(data);
    }

    return BitmapDescriptor.defaultMarker;
  }
}
