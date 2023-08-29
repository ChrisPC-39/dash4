//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:dash4/database/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../globals.dart';

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
  final List<Uint8List>? images;

  @HiveField(7)
  final List<Tag>? tags;

  Item({
    required this.name,
    required this.id,
    this.isSection = false,
    this.isSelected = false,
    this.isEditing = false,
    this.isVisible = true,
    this.images,
    this.tags,
  });
}

Future<void> addNewImages(
    List<Uint8List> images, Uint8List imageBytes, int index) async {
  var box = Hive.box(itemBoxName);

  images.add(imageBytes);
  updateItemImages(box: box, index: index, images: images);
}

Future<void> storeImage(Uint8List imageBytes, int index) async {
  List<Uint8List> images = [];
  var box = Hive.box(itemBoxName);

  List<dynamic>? allImages = (box.getAt(index) as Item).images;

  if (allImages != null) {
    images.addAll(allImages.cast<Uint8List>());
  }

  images.add(imageBytes);
  updateItemImages(box: box, index: index, images: images);
}

Future<List<Uint8List>> getImages() async {
  var box = Hive.box(itemBoxName);

  List<dynamic>? result = (box.getAt(0) as Item).images;

  return result!.cast<Uint8List>();
}

void updateItemName({
  required Box box,
  required int index,
  required String newTitle,
}) {
  final item = box.getAt(index) as Item;

  box.putAt(
    index,
    Item(
      id: item.id,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isEditing: item.isEditing,
      isVisible: item.isVisible,
      images: item.images,
      name: newTitle,
    ),
  );
}

void updateItemSelected({
  required Box box,
  required int index,
  required bool isSelected,
}) {
  final item = box.getAt(index) as Item;

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isEditing: item.isEditing,
      isVisible: item.isVisible,
      images: item.images,
      isSelected: isSelected,
    ),
  );
}

void updateItemEditing({
  required Box box,
  required int index,
  required bool isEditing,
}) {
  disableAllEditItems(box);

  final item = box.getAt(index) as Item;

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isVisible: item.isVisible,
      images: item.images,
      isEditing: isEditing,
    ),
  );
}

void disableAllEditItems(Box box) {
  for (int i = 0; i < box.length; i++) {
    final item = box.getAt(i) as Item;

    box.putAt(
      i,
      Item(
        id: item.id,
        name: item.name,
        isSection: item.isSection,
        isSelected: item.isSelected,
        isVisible: item.isVisible,
        images: item.images,
        isEditing: false,
      ),
    );
  }
}

void updateItemVisibility({
  required Box box,
  required int index,
  required bool isVisible,
}) {
  final item = box.getAt(index) as Item;

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isEditing: item.isEditing,
      images: item.images,
      isVisible: isVisible,
    ),
  );
}

void updateItemImages({
  required Box box,
  required int index,
  required List<Uint8List> images,
}) {
  final item = box.getAt(index) as Item;

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isEditing: item.isEditing,
      isVisible: item.isVisible,
      images: images,
    ),
  );
}
