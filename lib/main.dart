import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthenticationChangeNotifier(),
      builder: (context, _) => const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Pavoni',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          return const HomeScreen();
        },
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: <Widget>[
          const Expanded(
              child: Image(image: AssetImage('assets/silhouette.png'))),
          //const Spacer(),
          Text(
            "Local Pavoni",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline3,
          ),
          Text("Organizing Espresso Meet-ups",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5),
          AuthenticationWidget(key: key),
          const Spacer(),
        ],
      ),
    );
  }
}
