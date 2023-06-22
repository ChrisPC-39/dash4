import 'dart:io';

import 'package:dash4/database/category.dart';
import 'package:hive/hive.dart';

import '../../database/item.dart';

void printListOfItems(List itemList) {
  for (int i = 0; i < itemList.length; i++) {
    Item item = itemList[i];
    print("$i: ${item.name}");
  }

  print("-----------");
}

void onReorder(int oldIndex, int newIndex, Box box) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }

  int oldListIndex = -1, newListIndex = -1;
  List boxAsList = box.values.toList();
  List<List> groups = [];
  List<Item> subList = [];

  for (int i = 0; i < boxAsList.length; i++) {
    final Item item = boxAsList[i];

    if (item.isSection && !item.isVisible) {
      subList = [item];

      for (int j = i + 1; j < boxAsList.length; j++) {
        final Item subItem = boxAsList[j];

        if (subItem.isSection) {
          i = j - 1;
          break;
        }

        subList.add(subItem);
      }

      groups.add(subList);
    } else {
      groups.add([item]);
    }
  }

  groups.forEach((element) {
    List<String> pls = [];
    for (Item item in element) {
      pls.add(item.name);
    }
    print(pls);
  });
  print("=========");

  //find oldListIndex
  for (int i = 0; i < groups.length; i++) {
    if (groups[i].contains(boxAsList[oldIndex])) {
      oldListIndex = i;
    }
  }

  //find newListIndex
  if (newIndex > oldIndex) {
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].contains(boxAsList[newIndex])) {
        // print("New list index should be: ${i}");
        newListIndex = i;
        break;
      }
    }
  } else {
    if (newIndex == 0) {
      newListIndex = newIndex;
    } else {
      for (int i = 0; i < groups.length; i++) {
        if (groups[i].contains(boxAsList[newIndex - 1])) {
          // print("New list index should be: ${i + 1}");
          newListIndex = i + 1;
          break;
        }
      }
    }
  }

  var removedSection = groups.removeAt(oldListIndex);
  groups.insert(newListIndex, removedSection);
  // var copy = groups;
  // var removedSection = copy.removeAt(oldListIndex);
  // copy.insert(newListIndex, removedSection);
  //
  // copy.forEach((element) {
  //   List<String> pls = [];
  //   for (Item item in element) {
  //     pls.add(item.name);
  //   }
  //   print(pls);
  // });

  // print("OLD LIST INDEX: $oldListIndex");

  if (boxAsList[oldIndex].isSection && !boxAsList[oldIndex].isVisible) {
    List flattenedList = groups.expand((list) => list).toList();

    if(flattenedList.length > boxAsList.length) {
      flattenedList.removeRange(boxAsList.length, flattenedList.length);
    }

    for(int i = 0; i < flattenedList.length; i++) {
      final Item item = flattenedList[i];

      if(item.isSection) {
        for(int j = i + 1; j < flattenedList.length; j++) {
          Item subItem = flattenedList[j];

          if(subItem.isSection) {
            i = j;
            break;
          }

          flattenedList[j] = Item(
            name: subItem.name,
            id: subItem.id,
            isSelected: subItem.isSelected,
            isVisible: item.isVisible,
          );
        }
      }
    }

    for (int i = 0; i < box.length; i++) {
      box.putAt(i, flattenedList[i]);
    }
  } else {
    Item item = boxAsList.removeAt(oldIndex);

    if(!item.isSection && newIndex > 0) {
      final Item prevItem = boxAsList[newIndex - 1];

      item = Item(
        name: item.name,
        id: item.id,
        isSelected: item.isSelected,
        isVisible: prevItem.isVisible,
      );
    }

    boxAsList.insert(newIndex, item);

    for (int i = 0; i < box.length; i++) {
      box.putAt(i, boxAsList[i]);
    }
  }

  // if ((boxAsList[oldIndex] as Item).isSection &&
  //     !(boxAsList[oldIndex] as Item).isVisible) {
  //   List<Item> itemsToRemove = [boxAsList[oldIndex]];
  //
  //   int j = oldIndex + 1;
  //   for (int i = oldIndex + 1; i < boxAsList.length; i++) {
  //     final Item subItem = boxAsList[i];
  //
  //     if (subItem.isSection) {
  //       break;
  //     }
  //
  //     itemsToRemove.add(subItem);
  //     j = i;
  //   }
  //
  //   if (newIndex > oldIndex) {
  //     if (newIndex + 1 != boxAsList.length &&
  //         !boxAsList[newIndex + 1].isVisible &&
  //         !boxAsList[newIndex + 1].isSection) {
  //       for (int i = newIndex + 1; i < boxAsList.length; i++) {
  //         if (boxAsList[i].isSection) {
  //           newIndex = i;
  //         }
  //       }
  //     }
  //
  //     if(newIndex + 1 != boxAsList.length) {
  //       boxAsList.insertAll(newIndex, itemsToRemove);
  //     } else {
  //       boxAsList.insertAll(newIndex + 1, itemsToRemove);
  //     }
  //
  //     for (int i = oldIndex; i < j; i++) {
  //       boxAsList.removeAt(oldIndex);
  //     }
  //   } else {
  //     boxAsList.removeAt(oldIndex);
  //
  //     while (true) {
  //       if (oldIndex == boxAsList.length || boxAsList[oldIndex].isSection) {
  //         break;
  //       }
  //
  //       boxAsList.removeAt(oldIndex);
  //     }
  //
  //     boxAsList.insertAll(newIndex, itemsToRemove);
  //   }
  //
  //   for (int i = newIndex + 1; i < boxAsList.length; i++) {
  //     final Item subItem = boxAsList[i];
  //
  //     if (subItem.isSection) {
  //       break;
  //     }
  //
  //     final removedItem = Item(
  //       name: subItem.name,
  //       id: subItem.id,
  //       isSection: subItem.isSection,
  //       isSelected: subItem.isSelected,
  //       isEditing: subItem.isEditing,
  //       isVisible: false,
  //     );
  //
  //     boxAsList[i] = removedItem;
  //   }
  // } else {
  //   final Item item = boxAsList.removeAt(oldIndex);
  //   boxAsList.insert(newIndex, item);
  //
  //   if (!item.isSection) {
  //     if (!boxAsList[newIndex - 1].isVisible) {
  //       final removedItem = Item(
  //         name: item.name,
  //         id: item.id,
  //         isSection: item.isSection,
  //         isSelected: item.isSelected,
  //         isEditing: item.isEditing,
  //         isVisible: false,
  //       );
  //
  //       boxAsList[newIndex] = removedItem;
  //     }
  //   } else {
  //     if (newIndex + 1 != boxAsList.length &&
  //         !boxAsList[newIndex + 1].isVisible &&
  //         !boxAsList[newIndex + 1].isSection) {
  //       for (int i = newIndex + 1; i < boxAsList.length; i++) {
  //         if (boxAsList[i].isSection) {
  //           final Item item = boxAsList.removeAt(newIndex);
  //           boxAsList.insert(i - 1, item);
  //         }
  //       }
  //     }
  //   }
  // }

  // printListOfItems(boxAsList);
  // for (int i = 0; i < box.length; i++) {
  //   box.putAt(i, boxAsList[i]);
  // }
}

// void onReorder(int oldIndex, int newIndex, Box box) {
//   if (oldIndex < newIndex) {
//     newIndex--;
//   }
//
//   List boxAsList = [];
//   List<Item> subItems = [];
//   final Item currItem = box.getAt(oldIndex) as Item;
//   int totalHiddenItems = 0;
//
//   for(int i = 0; i < box.length; i++) {
//     final item = box.getAt(i) as Item;
//
//     if(!item.isVisible && !item.isSection) {
//       totalHiddenItems++;
//     }
//   }
//
//   if (currItem.isSection) {
//     for (int i = 0; i < box.length; i++) {
//       final item = box.getAt(i) as Item;
//
//       if (item.isVisible || (item.isSection && !item.isVisible)) {
//         boxAsList.add(item);
//       }
//     }
//
//     for (int i = oldIndex + 1; i < box.length; i++) {
//       final Item subItem = box.getAt(i) as Item;
//
//       if (subItem.isSection) {
//         break;
//       }
//
//       subItems.add(subItem);
//     }
//
//     printListOfItems(boxAsList);
//
//     print("$oldIndex - $totalHiddenItems = ${oldIndex - totalHiddenItems}");
//
//     //TODO: Can't move sections if some have hidden subItems
//     // final Item removedItem = boxAsList.removeAt(oldIndex);
//
//     Item removedItem;
//     if(boxAsList.length < oldIndex) {
//       removedItem = boxAsList.removeAt(oldIndex - totalHiddenItems + 1);
//     } else {
//       removedItem = boxAsList.removeAt(oldIndex);
//     }
//
//     if (newIndex > oldIndex) {
//       boxAsList.insert(newIndex - subItems.length, removedItem);
//     } else {
//       boxAsList.insert(newIndex, removedItem);
//     }
//
//     boxAsList.insertAll(boxAsList.indexOf(removedItem) + 1, subItems);
//   } else if(!currItem.isSection) {
//     boxAsList = box.values.toList();
//
//     Item removedItem = boxAsList.removeAt(oldIndex);
//
//     if(newIndex > 0) {
//       final Item prevItem = boxAsList[newIndex - 1];
//
//       removedItem = Item(
//         name: removedItem.name,
//         id: removedItem.id,
//         isSection: removedItem.isSection,
//         isSelected: removedItem.isSelected,
//         isEditing: removedItem.isEditing,
//         isVisible: prevItem.isVisible,
//         subItems: [],
//       );
//     }
//
//     boxAsList.insert(newIndex, removedItem);
//   }
//
//   if (currItem.isSection) {
//     final Item parentItem = boxAsList[newIndex];
//
//     for (int i = newIndex + 1; i < box.length; i++) {
//       final Item subItem = boxAsList[i];
//
//       if (subItem.isSection) {
//         break;
//       }
//
//       boxAsList[i] = Item(
//         name: subItem.name,
//         id: subItem.id,
//         isSection: subItem.isSection,
//         isSelected: subItem.isSelected,
//         isEditing: subItem.isEditing,
//         isVisible: parentItem.isVisible,
//         subItems: [],
//       );
//     }
//   }
//
//   for (int i = 0; i < box.length; i++) {
//     box.putAt(i, boxAsList[i]);
//   }
// }

void updateCategoryName({
  required Box box,
  required int index,
  required String newTitle,
}) {
  final category = box.getAt(index) as MyCategory;

  box.putAt(
    index,
    MyCategory(
      id: category.id,
      isVisible: category.isVisible,
      subItems: category.subItems,
      name: newTitle,
    ),
  );
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
      subItems: item.subItems,
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

void updateCategoryVisibility({
  required Box box,
  required int index,
  required bool isVisible,
}) {
  final category = box.getAt(index) as MyCategory;

  box.putAt(
    index,
    MyCategory(
      id: category.id,
      name: category.name,
      subItems: category.subItems,
      isVisible: isVisible,
    ),
  );
}
