import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorldChangeNotifier extends ChangeNotifier {
  WorldChangeNotifier() {
    init();
  }

  var world = <String, Country>{};

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

  State state(String countryName, String stateName) {
    var country = world[countryName];
    if (country != null && country.states.isNotEmpty) {
      var state = country.states[stateName];
      if (state != null) {
        return state;
      }
    }
    return State(37.42796133580664, -122.085749655962);
  }

  Future<void> init() async {
    var worldJson = await rootBundle.loadString("assets/world.json");
    dynamic dynamicWorld = jsonDecode(worldJson);
    for (dynamic dynamicCountry in dynamicWorld) {
      var states = <String, State>{};
      for (dynamic dynamicState in dynamicCountry["states"]) {
        states[dynamicState["name"]] = State(
            double.parse(dynamicState["latitude"]),
            double.parse(dynamicState["longitude"]));
      }
      world[dynamicCountry["name"]] = Country(
          double.parse(dynamicCountry["latitude"]),
          double.parse(dynamicCountry["longitude"]),
          states);
    }
    notifyListeners();
  }
}

class Country {
  final double latitude;
  final double longitude;
  final Map<String, State> states;
  Country(this.latitude, this.longitude, this.states);
}

class State {
  final double latitude;
  final double longitude;
  State(this.latitude, this.longitude);
}
