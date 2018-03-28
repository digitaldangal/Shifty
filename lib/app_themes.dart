import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData light = new ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.red,
      backgroundColor: Colors.red,
      fontFamily: 'Assistant',
      indicatorColor: Colors.deepOrange,
      dividerColor: Colors.blue,
      iconTheme: new IconThemeData(color: Colors.white));

  static final ThemeData loginScreen = light.copyWith(accentColor: Colors.blue[100], primaryColor: Colors.white);
  static final ThemeData mainScreen = light.copyWith(accentColor: Colors.blue, primaryColor: Colors.red);
}
