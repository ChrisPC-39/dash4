import 'package:hive/hive.dart';

import '../../../database/item.dart';
import 'list_methods.dart';

void onReorderListView(int oldIndex, int newIndex, Box box) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }

  List boxAsList = box.values.toList();

  if (boxAsList[oldIndex].isSection && !boxAsList[oldIndex].isVisible) {
    _onListReorder(oldIndex, newIndex, boxAsList, box);
  } else {
    _onItemReorder(oldIndex, newIndex, boxAsList, box);
  }

  checkSubItemVisibility(box);
}

void _onListReorder(int oldIndex, int newIndex, List boxAsList, Box box) {
  int oldListIndex = -1, newListIndex = -1;
  List<List> groups = _getGroups(boxAsList);

  oldListIndex = _findOldListIndex(oldIndex, boxAsList, groups);
  newListIndex = _findNewListIndex(newIndex, oldIndex, groups, boxAsList);

  var removedSection = groups.removeAt(oldListIndex);
  groups.insert(newListIndex, removedSection);

  List flattenedList = _getListFromGroups(boxAsList, groups);

  replaceBoxWithList(box, flattenedList);
}

void _onItemReorder(int oldIndex, int newIndex, List boxAsList, Box box) {
  Item item = boxAsList.removeAt(oldIndex);

  boxAsList.insert(newIndex, item);

  replaceBoxWithList(box, boxAsList);
}

List<List> _getGroups(List boxAsList) {
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

  return groups;
}

int _findOldListIndex(int oldIndex, List boxAsList, List<List> groups) {
  for (int i = 0; i < groups.length; i++) {
    if (groups[i].contains(boxAsList[oldIndex])) {
      return i;
    }
  }

  return -1;
}

int _findNewListIndex(
    int newIndex, int oldIndex, List<List> groups, List boxAsList) {
  if (newIndex == 0) {
    return newIndex;
  }

  if (newIndex > oldIndex) {
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].contains(boxAsList[newIndex])) {
        return i;
      }
    }
  } else {
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].contains(boxAsList[newIndex - 1])) {
        return i + 1;
      }
    }
  }

  return -1;
}

List _getListFromGroups(List boxAsList, List<List> groups) {
  List flattenedList = groups.expand((list) => list).toList();

  if (flattenedList.length > boxAsList.length) {
    flattenedList.removeRange(boxAsList.length, flattenedList.length);
  }

  return flattenedList;
}