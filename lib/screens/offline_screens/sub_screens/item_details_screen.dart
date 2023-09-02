import 'package:dash4/screens/offline_screens/offline_methods/item_methods.dart';
import 'package:dash4/widgets/image_gridview.dart';
import 'package:dash4/widgets/page_section_label.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../database/item.dart';
import '../../../database/tag.dart';
import '../../../globals.dart';
import '../../../widgets/subscreen_appbar_back.dart';
import 'image_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int index;

  const ItemDetailsScreen({
    super.key,
    required this.index,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController detailsController = TextEditingController();
  Item item = Item(name: "View item details", id: -1);
  List<bool> isSelected = [];

  @override
  void initState() {
    super.initState();

    if (widget.index >= 0) {
      item = Hive.box(itemBoxName).getAt(widget.index) as Item;
      detailsController.text = item.details;
    }

    for (int i = 0; i < Hive.box(tagBoxName).length; i++) {
      isSelected.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: subScreenAppBar(title: item.name, context: context),
        body: ValueListenableBuilder(
            valueListenable: Hive.box(itemBoxName).listenable(),
            builder: (context, itemBox, _) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetails(),
                      const PageSectionLabel(title: "Tags"),
                      _buildTags(),
                      const PageSectionLabel(title: "Images"),
                      ImageGridView(index: widget.index),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildDetails() {
    return TextField(
      maxLines: 10,
      controller: detailsController,
      onChanged: (newVal) {
        updateItemDetails(
          box: Hive.box(itemBoxName),
          index: widget.index,
          newDetails: newVal,
        );
      },
      decoration: InputDecoration(
        hintText: 'Item details',
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[100]!, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).buttonTheme.colorScheme!.background,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    int tagListLength = 0;

    if (hasTags(item)) {
      tagListLength = item.tags!.length;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: List.generate(
          tagListLength + 1,
          (index) {
            if (index == tagListLength) {
              return RawChip(
                label: const Text("Add tag"),
                backgroundColor: Colors.grey[200],
                avatar: const CircleAvatar(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                shape: const StadiumBorder(
                  side: BorderSide(width: 1),
                ),
                onPressed: () {
                  void updateSelected(List<bool> updatedList) {
                    setState(() {
                      isSelected = updatedList;
                    });
                  }

                  selectTagDialog(
                    context,
                    isSelected,
                    updateSelected,
                    () {
                      for (int i = 0; i < isSelected.length; i++) {
                        final tag = Hive.box(tagBoxName).getAt(i) as Tag;

                        if (isSelected[i]) {
                          setState(() {
                            addItemTag(
                              box: Hive.box(itemBoxName),
                              index: widget.index,
                              tagToAdd: tag.label,
                              tagColorToAdd: tag.color,
                            );
                          });
                        }
                      }
                    },
                  );
                },
              );
            }

            // print("TAGs:");
            // print(item.tags!.length);
            // print(item.tags);
            // print("COLORs:");
            // print(item.tagColors!.length);
            // print(item.tagColors);
            // print("----------------");

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: RawChip(
                showCheckmark: false,
                label: Text(
                  item.tags![index],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                selected: true,
                onSelected: (newVal) {
                  setState(() {
                    removeItemTag(
                      box: Hive.box(itemBoxName),
                      index: widget.index,
                      tagToRemove: item.tags![index],
                      tagColorToRemove: item.tagColors![index],
                    );

                    isSelected[index] = false;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Color(item.tagColors![index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
