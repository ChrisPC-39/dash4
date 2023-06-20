import 'package:hive/hive.dart';

import '../../database/item.dart';

void onReorder(int oldIndex, int newIndex, Box box) {
  if (oldIndex < newIndex) {
    newIndex--;
  }

  List boxAsList = [];
  List<Item> subItems = [];
  final Item currItem = box.getAt(oldIndex) as Item;

  if (currItem.isSection) {
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i) as Item;

      if (item.isVisible || (item.isSection && !item.isVisible)) {
        boxAsList.add(item);
      }
    }

    for (int i = oldIndex + 1; i < box.length; i++) {
      final Item subItem = box.getAt(i) as Item;

      if (subItem.isSection) {
        break;
      }

      subItems.add(subItem);
    }

    final Item removedItem = boxAsList.removeAt(oldIndex);

    if (newIndex > oldIndex) {
      boxAsList.insert(newIndex - subItems.length, removedItem);
    } else {
      boxAsList.insert(newIndex, removedItem);
    }

    boxAsList.insertAll(boxAsList.indexOf(removedItem) + 1, subItems);
  } else if(!currItem.isSection) {
    boxAsList = box.values.toList();

    Item removedItem = boxAsList.removeAt(oldIndex);

    if(newIndex > 0) {
      final Item prevItem = boxAsList[newIndex - 1];

      removedItem = Item(
        name: removedItem.name,
        id: removedItem.id,
        isSection: removedItem.isSection,
        isSelected: removedItem.isSelected,
        isEditing: removedItem.isEditing,
        isVisible: prevItem.isVisible,
        subItems: [],
      );
    }

    boxAsList.insert(newIndex, removedItem);
  }


  if (currItem.isSection) {
    final Item parentItem = boxAsList[newIndex];

    for (int i = newIndex + 1; i < box.length; i++) {
      final Item subItem = boxAsList[i];

      if (subItem.isSection) {
        break;
      }

      boxAsList[i] = Item(
        name: subItem.name,
        id: subItem.id,
        isSection: subItem.isSection,
        isSelected: subItem.isSelected,
        isEditing: subItem.isEditing,
        isVisible: parentItem.isVisible,
        subItems: [],
      );
    }
  }

  for (int i = 0; i < box.length; i++) {
    box.putAt(i, boxAsList[i]);
  }
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
      isEditing: item.isEditing,
      isSelected: item.isSelected,
      isVisible: item.isVisible,
      subItems: item.subItems,
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
      subItems: item.subItems,
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
      subItems: item.subItems,
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
        subItems: item.subItems,
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
      subItems: item.subItems,
      isVisible: isVisible,
    ),
  );
}
