import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_cnp.dart';
import 'main.dart';
import 'world_cnp.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
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
      if (!firebaseChangeNotifier.isSignedIn) {
        return Container();
      }

      return ListView(
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
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              var country = await _countryOrStateDialog(
                  context, worldChangeNotifier.countries());
              if (country != null) {
                firebaseChangeNotifier.setCountryState(
                    country, worldChangeNotifier.states(country)[0]);
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
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              var state = await _countryOrStateDialog(context,
                  worldChangeNotifier.states(firebaseChangeNotifier.country));
              if (state != null) {
                firebaseChangeNotifier.setCountryState(
                    firebaseChangeNotifier.country, state);
              }
            },
          ),
        ],
      );
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
