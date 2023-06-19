import 'package:hive/hive.dart';

import '../../database/item.dart';

void onReorder(int oldIndex, int newIndex, Box box) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }

  List boxAsList = box.values.toList();

  final initialItem = box.getAt(oldIndex) as Item;
  if(initialItem.isSection && !initialItem.isVisible) {
    List valuesToMove = [];

    valuesToMove.add(box.getAt(oldIndex) as Item);

    if(oldIndex > newIndex) {
      for(int i = oldIndex + 1; i < box.length; i++) {
        final subItem = box.getAt(i) as Item;

        if(subItem.isSection) {
          break;
        }

        valuesToMove.add(subItem);
      }

      valuesToMove = valuesToMove.reversed.toList();
      for (Item value in valuesToMove) {
        boxAsList.remove(value);
        boxAsList.insert(newIndex, value);
      }
    } else {
      for(int i = oldIndex + 1; i < newIndex; i++) {
        final subItem = box.getAt(i) as Item;

        if(subItem.isSection) {
          break;
        }

        valuesToMove.add(subItem);
      }

      for (Item value in valuesToMove) {
        boxAsList.remove(value);
        boxAsList.insert(newIndex, value);
      }
    }

  } else {
    final removedItem = boxAsList.removeAt(oldIndex);

    boxAsList.insert(newIndex, removedItem);
  }

  // for(var j = 0; j < box.length; j++) {
  //   final itm = box.getAt(j) as Item;
  //
  //   print(itm.name);
  // }
  //
  // print("-----------");
  //
  // for(var j = 0; j < boxAsList.length; j++) {
  //   final itm = boxAsList[j];
  //
  //   print(itm.name);
  // }
  //
  // print("DONE");

  for (int i = 0; i < box.length; i++) {
    box.putAt(i, boxAsList[i]);
  }

  final currItem = box.getAt(newIndex) as Item;
  if(currItem.isSection) {
    if(oldIndex > newIndex) {
      for (int i = newIndex + 1; i < box.length; i++) {
        final subItem = box.getAt(i) as Item;

        if (subItem.isSection) {
          break;
        }

        updateItemVisibility(
          box: box,
          index: i,
          isVisible: currItem.isVisible,
        );
      }
    } else {
      for (int i = oldIndex; i < box.length; i++) {
        final subItem = box.getAt(i) as Item;

        if (subItem.isSection) {
          break;
        }

        updateItemVisibility(
          box: box,
          index: i,
          isVisible: true,
        );
      }
    }
  } else if (newIndex > 0) {
    final prevItem = box.getAt(newIndex - 1) as Item;

    updateItemVisibility(
      box: box,
      index: newIndex,
      isVisible: prevItem.isVisible,
    );
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
      isVisible: isVisible,
    ),
  );
}
