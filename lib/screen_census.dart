import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'world_cnp.dart';

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
    return Consumer<WorldChangeNotifier>(
        builder: (context, worldChangeNotifier, child) {
      var countries = worldChangeNotifier.worldCensus().toList();
      return ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            var country = countries[index];
            var states =
                worldChangeNotifier.countryCensus(country.name).toList();
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
                    itemCount: states.length,
                    itemBuilder: (context, index) {
                      var state = states[index];
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
