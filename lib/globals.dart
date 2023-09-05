import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

const String itemBoxName = "itemBoxName${62}";
const String setupBoxName = "setupBoxName${3}";
const String tagBoxName = "tagBoxName${3}";

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

void showFlushbar(
    BuildContext context, {
      String title = "Field is empty",
      String message = "Please input something...",
    }) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    title: title,
    message: message,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}
