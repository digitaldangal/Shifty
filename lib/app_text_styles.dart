import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle snackbarText = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.normal,
      fontSize: 14.0,
      color: Colors.white);

  // Login Screen
  static TextStyle loginTextField = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.normal,
      fontSize: 17.0,
      color: Colors.white);
  static TextStyle loginTextFieldHint = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.normal,
      fontSize: 17.0,
      color: Colors.white70);
  static TextStyle loginButton = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.w600,
      fontSize: 20.0,
      color: const Color(0xFFD32F2F));
  static TextStyle loginLogo = const TextStyle(
      fontFamily: 'VarelaRound',
      fontWeight: FontWeight.normal,
      fontSize: 60.0,
      color: Colors.white);
  static TextStyle loginButtonGoogle = const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      fontSize: 17.0,
      color: Colors.black54);
  static TextStyle loginButtonFacebook = const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      fontSize: 17.0,
      color: Colors.white);
  static TextStyle loginTextTransparent = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.w600,
      fontSize: 17.0,
      color: const Color(0xFFEF9A9A));
  static TextStyle loginTextOpaque = const TextStyle(
      fontFamily: 'Assistant',
      fontWeight: FontWeight.w600,
      fontSize: 17.0,
      color: Colors.white);

  static TextStyle tabBarLabel = const TextStyle(
      fontFamily: 'Assistant', fontWeight: FontWeight.w600, fontSize: 16.5);
}
