//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:dash4/database/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../globals.dart';
import '../screens/offline_screens/offline_methods/list_methods.dart';

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
  final List<String>? tags;

  @HiveField(8)
  final List<int>? tagColors;

  @HiveField(9)
  final String details;

  Item({
    required this.name,
    required this.id,
    this.isSection = false,
    this.isSelected = false,
    this.isEditing = false,
    this.isVisible = true,
    this.details = "",
    this.images,
    this.tags,
    this.tagColors,
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

Future<void> addItemToBox(
    TextEditingController searchBar,
    List<String> tagLabels,
    List<int> tagColors,
    BuildContext context,
    ) async {
  final box = Hive.box(itemBoxName);
  List boxAsList = box.values.toList();
  box.add(Item(name: 'null', id: -1));

  boxAsList.insert(
    0,
    Item(
      name: searchBar.text,
      tags: tagLabels,
      tagColors: tagColors,
      id: box.length + 1,
    ),
  );

  replaceBoxWithList(box, boxAsList);
  searchBar.clear();
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
      tags: item.tags,
      tagColors: item.tagColors,
      details: item.details,
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
      tags: item.tags,
      tagColors: item.tagColors,
      details: item.details,
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
      tags: item.tags,
      tagColors: item.tagColors,
      details: item.details,
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
        tags: item.tags,
        tagColors: item.tagColors,
        details: item.details,
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
      tags: item.tags,
      tagColors: item.tagColors,
      details: item.details,
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
      tags: item.tags,
      tagColors: item.tagColors,
      details: item.details,
      images: images,
    ),
  );
}

void updateItemDetails({
  required Box box,
  required int index,
  required String newDetails,
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
      tags: item.tags,
      tagColors: item.tagColors,
      images: item.images,
      details: newDetails,
    ),
  );
}

void removeItemTag({
  required Box box,
  required int index,
  required String tagToRemove,
  required int tagColorToRemove,
}) {
  final item = box.getAt(index) as Item;

  List<String> newTags = item.tags!;
  List<int> newTagColors = item.tagColors!;

  newTags.removeWhere((element) => element == tagToRemove);
  newTagColors.removeWhere((element) => element == tagColorToRemove);

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isEditing: item.isEditing,
      isVisible: item.isVisible,
      images: item.images,
      details: item.details,
      tags: newTags,
      tagColors: newTagColors,
    ),
  );
}

void addItemTag({
  required Box box,
  required int index,
  required String tagToAdd,
  required int tagColorToAdd,
}) {
  final item = box.getAt(index) as Item;

  List<String> newTags = item.tags == null ? [] : item.tags!;
  List<int> newTagColors = item.tagColors == null ? [] : item.tagColors!;

  if(newTags.contains(tagToAdd)) {
    return;
  }

  newTags.add(tagToAdd);
  newTagColors.add(tagColorToAdd);

  box.putAt(
    index,
    Item(
      id: item.id,
      name: item.name,
      isSection: item.isSection,
      isSelected: item.isSelected,
      isEditing: item.isEditing,
      isVisible: item.isVisible,
      images: item.images,
      details: item.details,
      tags: newTags,
      tagColors: newTagColors,
    ),
  );
}