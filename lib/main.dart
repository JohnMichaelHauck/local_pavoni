import 'package:flutter/material.dart';
import 'package:local_pavoni/world.dart';
import 'package:provider/provider.dart';
import 'authentication.dart';

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
        create: (context) => AuthenticationChangeNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => WorldChangeNotifier(),
      )
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
      children: <Widget>[
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
    return Consumer<WorldChangeNotifier>(
        builder: (context, worldChangeNotifier, child) {
      return Column(
        children: [
          Row(children: [
            const Padding(
                padding: EdgeInsets.all(12.0), child: Icon(Icons.language)),
            DropdownButton(
              value: worldChangeNotifier.selectedCountry,
              items: worldChangeNotifier.countries.entries
                  .map<DropdownMenuItem<String>>((var country) {
                return DropdownMenuItem<String>(
                    value: country.key, child: Text(country.key));
              }).toList(),
              onChanged: (String? newValue) {
                worldChangeNotifier.selectedCountry = newValue!;
              },
            )
          ]),
          Row(children: [
            const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.person_pin_circle)),
            DropdownButton(
              value: worldChangeNotifier.selectedState,
              items: worldChangeNotifier
                  .countries[worldChangeNotifier.selectedCountry]
                  ?.map<DropdownMenuItem<String>>((var state) {
                return DropdownMenuItem<String>(
                    value: state, child: Text(state));
              }).toList(),
              onChanged: (String? newValue) {
                worldChangeNotifier.selectedState = newValue!;
              },
            )
          ]),
        ],
      );
    });
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
    return Consumer<AuthenticationChangeNotifier>(
        builder: (context, authenticationChangeNotifier, child) {
      return BottomNavigationBar(
        items: [
          if (authenticationChangeNotifier.isSignedIn) ...[
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
