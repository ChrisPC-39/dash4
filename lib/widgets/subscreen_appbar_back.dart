import 'package:flutter/material.dart';

PreferredSizeWidget subScreenAppBar({
  required String title,
  required BuildContext context,
}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    title: Text(title),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
