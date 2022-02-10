import 'package:flutter/material.dart';
import 'package:local_pavoni/firebase.dart';
import 'package:local_pavoni/world.dart';
import 'package:provider/provider.dart';
import 'firebase.dart';

// npm install -g firebase-tools
// flutter pub add firebase_core
// flutter pub add cloud_firestore
// flutter pub add provider
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

class SigninScreen extends StatelessWidget {
  const SigninScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signin / Signout'),
      ),
      body: SigninBody(key: key),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
    );
  }
}

class SigninBody extends StatelessWidget {
  const SigninBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
            width: 200,
            height: 200,
            child: Image(image: AssetImage('assets/silhouette.png'))),
        Text(
          "Local Pavoni",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        Text("Organizing Espresso Meet-ups",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: AuthenticationWidget(key: key)),
      ],
    );
  }
}

class MeScreen extends StatelessWidget {
  const MeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
      ),
      body: MeBody(key: key),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
    );
  }
}

class MeBody extends StatelessWidget {
  const MeBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseChangeNotifier, WorldChangeNotifier>(
        builder: (context, firebaseChangeNotifier, worldChangeNotifier, child) {
      return firebaseChangeNotifier.isSignedIn
          ? ListView(
              children: [
                Container(height: 16),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language),
                      Container(width: 8),
                      Text(firebaseChangeNotifier.country,
                          textAlign: TextAlign.center),
                      Container(width: 8),
                      const Icon(Icons.arrow_downward),
                    ],
                  ),
                  onTap: () async {
                    var country = await _countryOrStateDialog(
                        context, worldChangeNotifier.countries());
                    if (country != null) {
                      firebaseChangeNotifier.country = country;
                      firebaseChangeNotifier.state =
                          worldChangeNotifier.states(country)[0];
                    }
                  },
                ),
                Container(height: 16),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_pin),
                        Container(width: 8),
                        Text(firebaseChangeNotifier.state,
                            textAlign: TextAlign.center),
                        Container(width: 8),
                        const Icon(Icons.arrow_downward),
                      ],
                    ),
                  ),
                  onTap: () async {
                    var state = await _countryOrStateDialog(
                        context,
                        worldChangeNotifier
                            .states(firebaseChangeNotifier.country));
                    if (state != null) {
                      firebaseChangeNotifier.state = state;
                    }
                  },
                ),
              ],
            )
          : Container();
    });
  }

  Future<String?> _countryOrStateDialog(
      BuildContext context, List<String> options) async {
    String? retVal;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(children: [
            SizedBox(
                width: 200,
                height: 400,
                child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(options[index]),
                        onTap: () {
                          retVal = options[index];
                          Navigator.pop(context);
                        },
                      );
                    })),
          ]);
        });
    return retVal;
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Container(),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
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
