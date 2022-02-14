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

  Iterable<CensusCountry> worldCensus() sync* {
    for (var country in world.entries) {
      if (country.value.residents > 0) {
        yield CensusCountry(country.key, country.value.residents);
      }
    }
  }

  Iterable<CensusState> countryCensus(String countryName) sync* {
    var country = world[countryName];
    if (country != null) {
      for (var state in country.states.entries) {
        if (state.value.residents > 0) {
          yield CensusState(state.key, state.value.residents);
        }
      }
    }
  }

  void beginAddingResidents() {
    for (var country in world.values) {
      country.beginAddingResidents();
    }
  }

  void addResident(String countryName, String stateName) {
    var country = world[countryName];
    if (country != null && country.states.isNotEmpty) {
      country.residents++;
      var state = country.states[stateName];
      if (state != null) {
        state.residents++;
      }
    }
  }

  void endAddingResidents() {
    notifyListeners();
  }
}

class CensusCountry {
  final String name;
  final int census;
  CensusCountry(this.name, this.census);
}

class CensusState {
  final String name;
  final int census;
  CensusState(this.name, this.census);
}

class WorldCountry {
  final double latitude;
  final double longitude;
  final Map<String, WorldState> states;
  int residents = 0;
  WorldCountry(this.latitude, this.longitude, this.states);
  void beginAddingResidents() {
    residents = 0;
    for (var state in states.values) {
      state.beginAddingResidents();
    }
  }
}

class WorldState {
  final double latitude;
  final double longitude;
  int residents = 0;
  WorldState(this.latitude, this.longitude);
  void beginAddingResidents() {
    residents = 0;
  }
}
