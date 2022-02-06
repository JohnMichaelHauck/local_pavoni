import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorldChangeNotifier extends ChangeNotifier {
  WorldChangeNotifier() {
    init();
  }

  bool loaded = false;
  var countries = <String, List<String>>{};

  String _selectedCountry = "";
  String get selectedCountry => _selectedCountry;
  set selectedCountry(String selectedCountry) {
    _selectedCountry = selectedCountry;
    _selectedState = countries[selectedCountry]!.first;
    notifyListeners();
  }

  String _selectedState = "";
  String get selectedState => _selectedState;
  set selectedState(String selectedState) {
    _selectedState = selectedState;
    notifyListeners();
  }

  Future<void> init() async {
    var worldJson = await rootBundle.loadString("assets/world.json");
    var worldDecoded = jsonDecode(worldJson);
    for (dynamic country in worldDecoded) {
      List<String> states = [];
      for (dynamic state in country["states"]) {
        states.add(state["name"]);
      }
      if (states.isEmpty) {
        states.add(country["name"]);
      }
      countries[country["name"]] = states;
    }
    selectedCountry = countries.keys.first;
    loaded = true;
  }
}
