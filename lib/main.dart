import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen_census.dart';
import 'screen_cnp.dart';
import 'world_cnp.dart';
import 'firebase_cnp.dart';
import 'screen_signin.dart';
import 'screen_me.dart';
import 'screen_map.dart';

// npm install -g firebase-tools
// flutter pub add firebase_core
// flutter pub add cloud_firestore
// flutter pub add provider
// flutter pub add google_maps_flutter
// flutter pub add google_maps_flutter_web (because web is not yet supported in base code)
// npm install -g firebase-tools
// firebase login
// firebase init hosting
// firebase init (Firestore, Hosting, Functions)
// flutter build web
// firebase.json->"hosting": { "public": "build/web" ...
// firebase deploy

void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ScreenChangeNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => WorldChangeNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => FirebaseChangeNotifier(),
      ),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Local Pavoni',
        home: Consumer<ScreenChangeNotifier>(
          builder: (context, screenChangeNotifier, child) {
            switch (screenChangeNotifier.screen) {
              case ScreenEnum.screenSignin:
                return const SigninScreen();
              case ScreenEnum.screenMe:
                return const MeScreen();
              case ScreenEnum.screenCensus:
                return const CensusScreen();
              case ScreenEnum.screenMap:
                return const MapScreen();
            }
          },
        ));
  }
}

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenChangeNotifier>(
        builder: ((context, screenChangeNotifier, child) {
      return BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // annoyingly needed for more than three items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Signin/out"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Census"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              screenChangeNotifier.screen = ScreenEnum.screenSignin;
              break;
            case 1:
              screenChangeNotifier.screen = ScreenEnum.screenMe;
              break;
            case 2:
              screenChangeNotifier.screen = ScreenEnum.screenCensus;
              break;
            case 3:
              screenChangeNotifier.screen = ScreenEnum.screenMap;
              break;
            default:
          }
        },
      );
    }));
  }
}
