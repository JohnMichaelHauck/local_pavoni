import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorldChangeNotifier extends ChangeNotifier {
  WorldChangeNotifier() {
    init();
  }

  var world = <String, WorldCountry>{};

  Future<void> init() async {
    var worldJson = await rootBundle.loadString("assets/world.json");
    dynamic dynamicWorld = jsonDecode(worldJson);
    for (dynamic dynamicCountry in dynamicWorld) {
      var states = <String, WorldState>{};
      for (dynamic dynamicState in dynamicCountry["states"]) {
        states[dynamicState["name"]] = WorldState(
            double.parse(dynamicState["latitude"]),
            double.parse(dynamicState["longitude"]));
      }
      world[dynamicCountry["name"]] = WorldCountry(
          double.parse(dynamicCountry["latitude"]),
          double.parse(dynamicCountry["longitude"]),
          states);
    }
    notifyListeners();
  }

  List<String> countries() {
    return world.keys.toList();
  }

  List<String> states(String countryName) {
    var country = world[countryName];
    if (country != null && country.states.isNotEmpty) {
      return country.states.keys.toList();
    }
    return [countryName];
  }

  WorldState state(String countryName, String stateName) {
    var country = world[countryName];
    if (country != null && country.states.isNotEmpty) {
      var state = country.states[stateName];
      if (state != null) {
        return state;
      }
    }
    return WorldState(37.42796133580664, -122.085749655962);
  }
}

class WorldCountry {
  final double latitude;
  final double longitude;
  final Map<String, WorldState> states;
  WorldCountry(this.latitude, this.longitude, this.states);
}

class WorldState {
  final double latitude;
  final double longitude;
  WorldState(this.latitude, this.longitude);
}
