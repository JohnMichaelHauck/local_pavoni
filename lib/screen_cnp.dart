import 'package:flutter/material.dart';

enum ScreenEnum {
  screenSignin,
  screenMe,
  screenMap,
}

class ScreenChangeNotifier extends ChangeNotifier {
  ScreenEnum _screenEnum = ScreenEnum.screenSignin;
  ScreenEnum get screen => _screenEnum;
  set screen(ScreenEnum screenEnum) {
    _screenEnum = screenEnum;
    notifyListeners();
  }
}
