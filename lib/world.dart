import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorldChangeNotifier extends ChangeNotifier {
  WorldChangeNotifier() {
    init();
  }

  var world = <String, List<String>>{};

  List<String> countries() {
    return world.keys.toList();
  }

  List<String> states(String country) {
    return world.containsKey(country) ? world[country] ?? [country] : [country];
  }

  Future<void> init() async {
    var worldJson = await rootBundle.loadString("assets/world.json");
    var worldDecoded = jsonDecode(worldJson);
    for (dynamic country in worldDecoded) {
      var states = <String>[];
      for (dynamic state in country["states"]) {
        states.add(state["name"]);
      }
      world[country["name"]] = states;
    }
    notifyListeners();
  }
}
