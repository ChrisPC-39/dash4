//flutter pub run build_runner build --delete-conflicting-outputs

import 'dart:ui';

import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 2)
class Tag {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int color;

  Tag({
    required this.label,
    required this.color,
  });
}
