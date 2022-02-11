import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'world.dart';
import 'firebase.dart';
import 'signin_screen.dart';
import 'me_screen.dart';
import 'map_screen.dart';

// npm install -g firebase-tools
// flutter pub add firebase_core
// flutter pub add cloud_firestore
// flutter pub add provider
// flutter pub add google_maps_flutter
// flutter pub add google_maps_flutter_web (because web is not yet supported in base code)
// npm install -g firebase-tools
// firebase login
// firebase init hosting
// firebase init
// flutter build web
// firebase deploy

void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => FirebaseChangeNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => WorldChangeNotifier(),
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
      routes: {
        "/": (context) => const SigninScreen(),
        "/me": (context) => const MeScreen(),
        "/map": (context) => const MapScreen(),
      },
    );
  }
}

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseChangeNotifier>(
        builder: (context, firebaseChangeNotifier, child) {
      return BottomNavigationBar(
        items: [
          if (firebaseChangeNotifier.isSignedIn) ...[
            const BottomNavigationBarItem(
                icon: Icon(Icons.logout), label: "Signout")
          ] else ...[
            const BottomNavigationBarItem(
                icon: Icon(Icons.login), label: "Signin")
          ],
          const BottomNavigationBarItem(
              icon: Icon(Icons.info), label: "About me"),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        ],
        onTap: (i) => {
          Navigator.pushReplacementNamed(context, ["/", "/me", "/map"][i])
        },
      );
    });
  }
}
