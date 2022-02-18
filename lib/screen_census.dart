import 'package:flutter/material.dart';
import 'package:local_pavoni/firebase_cnp.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'firebase_cnp.dart';

class CensusScreen extends StatelessWidget {
  const CensusScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Census'),
      ),
      body: CensusBody(key: key),
      bottomNavigationBar: HomeBottomNavigationBar(key: key),
    );
  }
}

class CensusBody extends StatelessWidget {
  const CensusBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseChangeNotifier>(
        builder: (context, firebaseChangeNotifier, child) {
      if (!firebaseChangeNotifier.isSignedIn) {
        return Container();
      }

      var countries = firebaseChangeNotifier.censusCountries;
      return ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            var country = countries[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.language),
                      Container(width: 8),
                      Text(country.name),
                      Container(width: 8),
                      Chip(label: Text(country.census.toString())),
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true, // needed to nest ListViews
                    physics:
                        const ClampingScrollPhysics(), // needed to nest ListViews
                    itemCount: country.states.length,
                    itemBuilder: (context, index) {
                      var state = country.states[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(width: 32),
                            const Icon(Icons.location_pin),
                            Container(width: 8),
                            Text(state.name),
                            Container(width: 8),
                            Chip(label: Text(state.census.toString())),
                          ],
                        ),
                      );
                    }),
              ],
            );
          });
    });
  }
}
