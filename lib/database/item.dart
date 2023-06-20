//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isSection;

  @HiveField(3)
  final bool isSelected;

  @HiveField(4)
  final bool isEditing;

  @HiveField(5)
  final bool isVisible;

  @HiveField(6)
  final List<int> subItems;

  Item({
    required this.name,
    required this.id,
    this.isSection = false,
    this.isSelected = false,
    this.isEditing = false,
    this.isVisible = true,
    this.subItems = const [],
  });
}
