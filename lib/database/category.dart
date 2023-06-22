//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class MyCategory {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isVisible;

  @HiveField(3)
  final List subItems;

  MyCategory({
    required this.name,
    required this.id,
    this.isVisible = true,
    this.subItems = const [],
  });
}
