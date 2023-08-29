import 'dart:ffi';

import 'package:another_flushbar/flushbar.dart';
import 'package:dash4/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../../database/item.dart';

void printListOfItems(List itemList) {
  for (int i = 0; i < itemList.length; i++) {
    Item item = itemList[i];
    print("$i: ${item.name}");
  }

  print("-----------");
}

Future<void> addItemToBox(
  TextEditingController searchBar,
  BuildContext context,
) async {
  final box = Hive.box(itemBoxName);
  List boxAsList = box.values.toList();
  box.add(Item(name: 'null', id: -1));

  boxAsList.insert(
    0,
    Item(
      name: searchBar.text,
      id: box.length + 1,
    ),
  );

  replaceBoxWithList(box, boxAsList);
  searchBar.clear();
}

void addSectionToBox(TextEditingController searchBar, BuildContext context) {
  if (searchBar.text.isEmpty) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: "Field is empty",
      message: "Please input something...",
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);

    return;
  }

  final box = Hive.box(itemBoxName);
  List boxAsList = box.values.toList();
  box.add(Item(name: 'null', id: -1, isSection: true));

  boxAsList.insert(
      0,
      Item(
        name: searchBar.text,
        id: box.length + 1,
        isSection: true,
      ));

  replaceBoxWithList(box, boxAsList);
  searchBar.clear();
}

void deleteSectionDialog(
    Item section, Box box, int index, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete sub-items?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                for (int i = index + 1; i < box.length; i++) {
                  final Item item = box.getAt(i);

                  if (item.isSection) {
                    break;
                  }

                  updateItemVisibility(box: box, index: i, isVisible: true);
                }

                box.deleteAt(index);
                Navigator.pop(context);
              },
              child: const Text("Don't delete sub-items"),
            ),
            const SizedBox(height: 10),
            const Text('or'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                box.deleteAt(index);
                int i = index;

                while (true) {
                  if (i > box.length) {
                    break;
                  }

                  final Item subItem = box.getAt(i);

                  if (subItem.isSection) {
                    break;
                  }

                  box.deleteAt(i);
                  i++;
                }

                Navigator.pop(context);
              },
              child: const Text(
                "Delete all sub-items",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      );
    },
  );
}

void replaceBoxWithList(Box box, List list) {
  for (int i = 0; i < box.length; i++) {
    box.putAt(i, list[i]);
  }
}

void handleSectionTap(int index, Item item, Box box) {
  final startSection = index;
  updateItemVisibility(
    box: box,
    index: startSection,
    isVisible: !item.isVisible,
  );

  checkSubItemVisibility(box);
}

void checkSubItemVisibility(Box box) {
  for (int i = 0; i < box.length; i++) {
    final Item item = box.getAt(i);

    if (item.isSection) {
      for (int j = i + 1; j < box.length; j++) {
        final Item subItem = box.getAt(j);

        if (subItem.isSection) {
          break;
        }

        updateItemVisibility(box: box, index: j, isVisible: item.isVisible);
      }
    }
  }
}

void showEditDialog(BuildContext context, Item item, Box box, int index) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController textEditingController =
          TextEditingController(text: item.name);

      return AlertDialog(
        title: const Text('Enter Text'),
        content: TextField(
          autofocus: true,
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: 'Type something...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              updateItemName(
                box: box,
                index: index,
                newTitle: textEditingController.text,
              );
              Navigator.of(context).pop();
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Theme.of(context).buttonTheme.colorScheme!.background,
              ),
            ),
          ),
        ],
      );
    },
  );
}
