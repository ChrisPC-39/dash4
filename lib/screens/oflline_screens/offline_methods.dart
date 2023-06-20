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

// void onReorder(int oldIndex, int newIndex, Box box) {
//   if (oldIndex < newIndex) {
//     newIndex--;
//   }
//
//   List boxAsList = box.values.toList();
//   final startItem = box.getAt(oldIndex) as Item;
//
//   if (!startItem.isSection) {
//     Item removedItem = boxAsList.removeAt(oldIndex) as Item;
//
//     for (int i = newIndex - 1; i >= 0; i--) {
//       final subItem = boxAsList[i] as Item;
//
//       if (subItem.isSection) {
//         removedItem = Item(
//           name: removedItem.name,
//           id: removedItem.id,
//           isSection: false,
//           isEditing: false,
//           isSelected: removedItem.isSelected,
//           isVisible: subItem.isVisible,
//           subItems: [],
//         );
//         break;
//       }
//     }
//
//     boxAsList.insert(newIndex, removedItem);
//   } else if(startItem.isSection) {
//     if (startItem.isVisible) {
//       Item removedItem = boxAsList.removeAt(oldIndex) as Item;
//
//       boxAsList.insert(newIndex, removedItem);
//     } else if(!startItem.isVisible) {
//       if(newIndex > oldIndex) {
//         List<Item> itemsToMove = [];
//
//         itemsToMove.add(boxAsList[oldIndex]);
//
//         for(int i = oldIndex + 1; i < boxAsList.length; i++) {
//           final Item subItem = boxAsList[i];
//
//           if(subItem.isSection) {
//             break;
//           }
//
//           itemsToMove.add(boxAsList[i]);
//         }
//
//         printListOfItems(itemsToMove);
//
//         printListOfItems(boxAsList);
//
//         print("NEW INDEX: $newIndex -> ${boxAsList[newIndex].name}");
//         print("----------");
//
//         boxAsList.insertAll(newIndex + 1, itemsToMove);
//
//         printListOfItems(boxAsList);
//
//         for(int i = 0; i < newIndex; i++) {
//           for(int j = 0; j < itemsToMove.length; j++) {
//             if(boxAsList[i].id == itemsToMove[j].id) {
//               boxAsList.removeAt(i);
//               itemsToMove.removeAt(j);
//             }
//           }
//         }
//
//         printListOfItems(boxAsList);
//         print(boxAsList.length);
//         print(box.length);
//         print("boxAsList length and box length ^^^");
//       }
//
//       // Item removedItem = boxAsList.removeAt(oldIndex) as Item;
//       //
//       // boxAsList.insert(newIndex, removedItem);
//       //
//       // if (newIndex < oldIndex) {
//       //   for (int i = oldIndex + 1; i < boxAsList.length; i++) {
//       //     final Item subItem = boxAsList[i];
//       //
//       //     if (subItem.isSection) {
//       //       break;
//       //     }
//       //
//       //     Item removedItem = boxAsList.removeAt(i) as Item;
//       //
//       //     boxAsList.insert(newIndex + 1, removedItem);
//       //   }
//       // } else {
//       //   List<Item> itemsToAdd = [];
//       //
//       //   for (int i = oldIndex; i < boxAsList.length; i++) {
//       //     final Item subItem = boxAsList[i];
//       //
//       //     if (subItem.isSection) {
//       //       break;
//       //     }
//       //
//       //     itemsToAdd.add(subItem);
//       //
//       //     boxAsList[i] = Item(
//       //       name: "-1",
//       //       id: -1,
//       //       isVisible: subItem.isVisible,
//       //       isEditing: false,
//       //       isSelected: subItem.isSelected,
//       //       isSection: subItem.isSection,
//       //     );
//       //   }
//       //
//       //   boxAsList.insertAll(newIndex + 1, itemsToAdd);
//       //
//       //   for(int i = 0; i < boxAsList.length; i++) {
//       //     final Item subItem = boxAsList[i];
//       //
//       //     if(subItem.id == -1 && subItem.name == "-1") {
//       //       boxAsList.removeAt(i);
//       //     }
//       //   }
//       // }
//
//       // for (int i = 0; i < removedItem.subItems.length; i++) {
//       //   final currSubItemIndex = removedItem.subItems[i];
//       //
//       //   Item removedSubItem = boxAsList.removeAt(currSubItemIndex) as Item;
//       //
//       //   boxAsList.insert(newIndex, removedSubItem);
//       // }
//     }
//   }
//
//   for (int i = 0; i < boxAsList.length; i++) {
//     final Item item = boxAsList[i];
//     List<int> newSubItems = [];
//
//     if (item.isSection) {
//       for (int j = i + 1; j < boxAsList.length; j++) {
//         final Item subItem = boxAsList[j];
//
//         if (!subItem.isSection) {
//           newSubItems.add(subItem.id);
//         } else {
//           break;
//         }
//       }
//
//       boxAsList[i] = Item(
//         name: item.name,
//         id: item.id,
//         isSection: item.isSection,
//         isSelected: item.isSelected,
//         isEditing: item.isEditing,
//         isVisible: item.isVisible,
//         subItems: newSubItems,
//       );
//     }
//   }
//
//   for (int i = 0; i < box.length; i++) {
//     box.putAt(i, boxAsList[i]);
//   }
// }

void printListOfItems(List itemList) {
  for (Item item in itemList) {
    print(item.name);
  }

  print("-----------");
}

// void onReorder(int oldIndex, int newIndex, Box box) {
//   if (oldIndex < newIndex) {
//     newIndex -= 1;
//   }
//
//   List boxAsList = box.values.toList();
//
//   final initialItem = box.getAt(oldIndex) as Item;
//   if(initialItem.isSection && !initialItem.isVisible) {
//     List valuesToMove = [];
//
//     valuesToMove.add(box.getAt(oldIndex) as Item);
//
//     if(oldIndex > newIndex) {
//       for(int i = oldIndex + 1; i < box.length; i++) {
//         final subItem = box.getAt(i) as Item;
//
//         if(subItem.isSection) {
//           break;
//         }
//
//         valuesToMove.add(subItem);
//       }
//
//       valuesToMove = valuesToMove.reversed.toList();
//       for (Item value in valuesToMove) {
//         boxAsList.remove(value);
//         boxAsList.insert(newIndex, value);
//       }
//     } else {
//       for(int i = oldIndex + 1; i < newIndex; i++) {
//         final subItem = box.getAt(i) as Item;
//
//         if(subItem.isSection) {
//           break;
//         }
//
//         valuesToMove.add(subItem);
//       }
//
//       for (Item value in valuesToMove) {
//         boxAsList.remove(value);
//         boxAsList.insert(newIndex, value);
//       }
//     }
//
//   } else {
//     final removedItem = boxAsList.removeAt(oldIndex);
//
//     boxAsList.insert(newIndex, removedItem);
//   }
//
//   for (int i = 0; i < box.length; i++) {
//     box.putAt(i, boxAsList[i]);
//   }
//
//   final currItem = box.getAt(newIndex) as Item;
//   if(currItem.isSection) {
//     if(oldIndex > newIndex) {
//       for (int i = newIndex + 1; i < box.length; i++) {
//         final subItem = box.getAt(i) as Item;
//
//         if (subItem.isSection) {
//           break;
//         }
//
//         updateItemVisibility(
//           box: box,
//           index: i,
//           isVisible: currItem.isVisible,
//         );
//       }
//     } else {
//       for (int i = oldIndex; i < box.length; i++) {
//         final subItem = box.getAt(i) as Item;
//
//         if (subItem.isSection) {
//           break;
//         }
//
//         updateItemVisibility(
//           box: box,
//           index: i,
//           isVisible: true,
//         );
//       }
//     }
//   } else if (newIndex > 0) {
//     final prevItem = box.getAt(newIndex - 1) as Item;
//
//     updateItemVisibility(
//       box: box,
//       index: newIndex,
//       isVisible: prevItem.isVisible,
//     );
//   }
// }

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
