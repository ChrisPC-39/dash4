import 'dart:io';

import 'package:dash4/globals.dart';
import 'package:dash4/screens/oflline_screens/sub_screens/list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'database/item.dart';
import 'database/setup.dart';
import 'screens/oflline_screens/item_view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory appDocumentDirectory;

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }

  Hive.registerAdapter(ItemAdapter());
  Hive.registerAdapter(SetupAdapter());

  await Hive.openBox(itemBoxName);
  await Hive.openBox(setupBoxName);

  final itemBox = Hive.box(itemBoxName);
  final setupBox = Hive.box(setupBoxName);

  if (itemBox.isEmpty) {
    final item1 = Item(id: 1, name: 'Item 1');
    final item2 = Item(id: 2, name: 'Item 2');
    final item3 = Item(id: 3, name: 'Item 3');
    final item4 = Item(id: 4, name: 'Item 4');
    final item5 = Item(id: 6, name: 'Item 5', isSection: true);
    final item6 = Item(id: 6, name: 'Item 6', isSection: true);
    final item7 = Item(id: 7, name: 'Item 7', isSection: true);
    final item8 = Item(id: 8, name: 'Item 8');
    final item9 = Item(id: 9, name: 'Item 9');
    itemBox.add(item1);
    itemBox.add(item2);
    itemBox.add(item3);
    itemBox.add(item4);
    itemBox.add(item5);
    itemBox.add(item6);
    itemBox.add(item7);
    itemBox.add(item8);
    itemBox.add(item9);
  }

  if(setupBox.isEmpty) {
    setupBox.add(Setup());
  }

  runApp(MaterialApp(
    home: const MyApp(),
    debugShowCheckedModeBanner: false,
    theme: setupBox.getAt(0).isDarkTheme ? darkTheme : lightTheme,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(setupBoxName).listenable(),
      builder: (context, setupBox, _) {
        final Setup setup = setupBox.getAt(0);

        return ItemViewScreen(setup: setup);
      }
    );
  }
}
