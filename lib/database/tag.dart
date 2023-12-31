//flutter pub run build_runner build --delete-conflicting-outputs

import 'package:dash4/globals.dart';
import 'package:dash4/screens/offline_screens/offline_methods/item_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'item.dart';

part 'tag.g.dart';

@HiveType(typeId: 2)
class Tag {
  //UNIQUE FIELD
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int color;

  @HiveField(2)
  bool isEditing;

  Tag({
    required this.label,
    required this.color,
    this.isEditing = false,
  });
}

bool doesTagBoxContainLabel(String label) {
  return Hive.box(tagBoxName)
      .values
      .any((tag) => tag is Tag && tag.label == label);
}

void addNewTag({
  required Box box,
  required String label,
  required int color,
  required BuildContext context,
}) {
  if (doesTagBoxContainLabel(label)) {
    showFlushbar(
      context,
      title: "A tag with this label already exists",
      message: "Please input a different label...",
    );

    return;
  }

  box.add(
    Tag(
      label: label,
      color: color,
      isEditing: false,
    ),
  );
}

void disableAllEditTags(Box box) {
  for (int i = 0; i < box.length; i++) {
    final tag = box.getAt(i) as Tag;

    box.putAt(
      i,
      Tag(
        label: tag.label,
        color: tag.color,
        isEditing: false,
      ),
    );
  }
}

void updateTagEditing({
  required Box box,
  required int index,
  required bool isEditing,
}) {
  disableAllEditTags(box);

  final tag = box.getAt(index) as Tag;

  box.putAt(
    index,
    Tag(
      label: tag.label,
      color: tag.color,
      isEditing: isEditing,
    ),
  );
}

void updateTagLabel({
  required Box box,
  required int index,
  required String newLabel,
  required BuildContext context,
}) {
  if (doesTagBoxContainLabel(newLabel)) {
    showFlushbar(
      context,
      title: "A tag with this label already exists",
      message: "Please input a different label...",
    );

    return;
  }

  if(!validateInputEmpty(context: context, input: newLabel)) {
    return;
  }

  final tag = box.getAt(index) as Tag;

  box.putAt(
    index,
    Tag(
      color: tag.color,
      isEditing: tag.isEditing,
      label: newLabel,
    ),
  );
}

void updateTagColor({
  required Box box,
  required int index,
  required int newColor,
  required BuildContext context,
}) {
  final tag = box.getAt(index) as Tag;

  box.putAt(
    index,
    Tag(
      isEditing: tag.isEditing,
      label: tag.label,
      color: newColor,
    ),
  );
}

void deleteTag({
  required Box box,
  required int index,
  required BuildContext context,
}) {
  final tag = box.getAt(index) as Tag;
  final itemBox = Hive.box(itemBoxName);

  for(int i = 0; i < itemBox.length; i++) {
    final item = itemBox.getAt(i) as Item;

    if(item.tagPointer == null) {
      continue;
    }

    for(int j = 0; j < item.tagPointer!.length; j++) {
      if(item.tagPointer![j] == index) {
        item.tagPointer!.removeAt(j);
        break;
      }
    }
  }

  box.deleteAt(index);
}