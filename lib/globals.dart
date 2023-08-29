import 'package:flutter/material.dart';

const String itemBoxName = "itemBoxName${53}";
const String setupBoxName = "setupBoxName${3}";
const String tagBoxName = "tagBoxName${0}";

ThemeData lightTheme = ThemeData.light().copyWith(
  useMaterial3: true,
  cardColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFFfafafa),
  iconTheme: const IconThemeData(color: Colors.grey),
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(iconColor: MaterialStateProperty.all(Colors.grey))),
  buttonTheme: ButtonThemeData(
    colorScheme: const ColorScheme.light().copyWith(
      background: Colors.blue[400],
    ),
  ),
  checkboxTheme:
      CheckboxThemeData(fillColor: MaterialStateProperty.all(Colors.grey)),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  useMaterial3: true,
  buttonTheme: ButtonThemeData(
    colorScheme: const ColorScheme.light().copyWith(
      background: Colors.purple[400],
    ),
  ),
);
