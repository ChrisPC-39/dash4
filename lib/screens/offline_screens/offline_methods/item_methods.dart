import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../database/item.dart';
import '../../../database/tag.dart';
import '../../../globals.dart';
import 'image_storage_methods.dart';

bool validateInputEmpty(
    {required BuildContext context,
    required String input,
    String title = "Field is empty",
    String message = "Please input something..."}) {
  if (input.isEmpty) {
    showFlushbar(
      context,
      title: "Field is empty",
      message: "Please input something...",
    );

    return false;
  }

  return true;
}

void addNewItemWithTags({
  required List<bool> isSelected,
  required TextEditingController controller,
  required BuildContext context,
  required Function(int index) updateSelectedList,
}) {
  List<String> tagLabels = [];
  List<int> tagColors = [];

  for (int i = 0; i < isSelected.length; i++) {
    if (isSelected[i]) {
      final tag = Hive.box(tagBoxName).getAt(i) as Tag;

      tagLabels.add(tag.label);
      tagColors.add(tag.color);

      isSelected[i] = false;
      updateSelectedList(i);
    }
  }

  addItemToBox(
    controller,
    tagLabels,
    tagColors,
    context,
  );
}

void addImagesToNewItem({
  required List<Uint8List>? cachedImages,
  required Function() clearCacheCallback,
}) {
  if (!hasImages(cachedImages)) {
    return;
  }

  for (var element in cachedImages!) {
    storeImage(element, 0);
  }

  clearCacheCallback();
}

void showFlushbar(
  BuildContext context, {
  required String title,
  required String message,
}) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    title: title,
    message: message,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}

void selectTagDialog(
  BuildContext context,
  List<bool> isSelected,
  Function(List<bool>) updateSelected,
  Function() onDonePressed,
) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(builder: (context, constraints) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Choose tags"),
            actions: [
              TextButton(
                child: const Text("Done"),
                onPressed: () {
                  onDonePressed();
                  Navigator.of(context).pop();
                },
              )
            ],
            content: SizedBox(
              width: constraints.maxWidth * .9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Hive.box(tagBoxName).length,
                itemBuilder: (buildContext, tagIndex) {
                  final tag = Hive.box(tagBoxName).getAt(tagIndex) as Tag;

                  List<String> words = tag.label.split(' ');
                  String initials = words.map((word) => word[0]).join();

                  return CheckboxListTile(
                    value: isSelected[tagIndex],
                    activeColor: Color(tag.color),
                    title: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(tag.color),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(tag.label),
                      ],
                    ),
                    onChanged: (newVal) {
                      setState(() {
                        isSelected[tagIndex] = newVal!;
                        updateSelected(isSelected);
                      });
                    },
                  );
                },
              ),
            ),
          );
        });
      });
    },
  );
}
