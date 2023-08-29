//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:dash4/globals.dart';
import 'package:hive/hive.dart';

part 'setup.g.dart';

@HiveType(typeId: 0)
class Setup {
  @HiveField(0)
  final double fontSize;

  @HiveField(1)
  final double itemSize;

  @HiveField(2)
  final bool useEnter;

  @HiveField(3)
  final bool isReverse;

  @HiveField(4)
  final bool isDarkTheme;

  @HiveField(5)
  final bool isListView;

  Setup({
    this.fontSize = 20,
    this.itemSize = 65,
    this.useEnter = false,
    this.isReverse = false,
    this.isDarkTheme = false,
    this.isListView = true,
  });
}

void toggleListView() {
  final box = Hive.box(setupBoxName);

  final Setup currSetup = box.getAt(0);

  box.putAt(0, Setup(
    fontSize: currSetup.fontSize,
    itemSize: currSetup.itemSize,
    useEnter: currSetup.useEnter,
    isReverse: currSetup.isReverse,
    isDarkTheme: currSetup.isDarkTheme,
    isListView: !currSetup.isListView,
  ));
}
