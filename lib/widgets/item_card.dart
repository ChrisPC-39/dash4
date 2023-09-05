import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:badges/badges.dart' as badges;

import '../database/editable_object.dart';
import '../database/item.dart';
import '../database/setup.dart';
import '../database/tag.dart';
import '../globals.dart';
import '../screens/offline_screens/offline_methods/image_storage_methods.dart';
import '../screens/offline_screens/offline_methods/item_methods.dart';
import '../screens/offline_screens/offline_methods/list_methods.dart';
import '../screens/offline_screens/sub_screens/image_screen.dart';
import '../screens/offline_screens/sub_screens/item_details_screen.dart';
import 'cancel_button_with_secondary_action.dart';
import 'check_button_with_secondary_action.dart';
import 'editable_text_with_textfield.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final int index;
  final Box box;

  const ItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.box,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Color? itemColor;
  Setup setup = Setup();
  final tagBox = Hive.box(tagBoxName);
  TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    itemColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(setupBoxName).listenable(),
        builder: (context, setupBox, _) {
          setup = Hive.box(setupBoxName).getAt(0);

          return Stack(
            key: ValueKey(widget.item.id),
            children: [
              badges.Badge(
                badgeContent: Container(),
                position: badges.BadgePosition.topStart(top: 0, start: 5),
                showBadge: hasImages(widget.item.images) && setup.isListView,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(
                        index: widget.index,
                      ),
                    ),
                  );
                },
                badgeStyle: const badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: Colors.grey,
                  padding: EdgeInsets.all(5),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ReorderableDelayedDragStartListener(
                    index: widget.index,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: widget.item.isSelected
                            ? Color.lerp(itemColor, Colors.grey, 0.5)
                            : itemColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Visibility(
                              visible: hasImages(widget.item.images) &&
                                  !setup.isListView,
                              child: SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: hasImages(widget.item.images)
                                      ? widget.item.images!.length + 1
                                      : 0,
                                  itemBuilder: (context, imageIndex) {
                                    if (imageIndex ==
                                        widget.item.images!.length) {
                                      return SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            children: [
                                              Container(
                                                  color: Colors.grey[200]),
                                              const Center(
                                                  child:
                                                      Icon(Icons.open_in_new)),
                                              Positioned.fill(
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    splashColor: Colors.black
                                                        .withOpacity(0.25),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ImageScreen(
                                                            index: widget.index,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final image =
                                        widget.item.images![imageIndex];

                                    return Row(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.memory(image),
                                            ),
                                            Positioned.fill(
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  splashColor: Colors.black
                                                      .withOpacity(0.25),
                                                  onTap: () {
                                                    showImageDialog(
                                                      context: context,
                                                      imageBytes: image,
                                                      onDelete: () {
                                                        final List<Uint8List>
                                                            images =
                                                            widget.item.images!;
                                                        images.remove(image);

                                                        updateItemImages(
                                                          box: Hive.box(
                                                              itemBoxName),
                                                          index: widget.index,
                                                          images: images,
                                                        );

                                                        setState(() {});
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CancelButtonWithSecondaryAction(
                                  editableObject: EditableObject(
                                    name: widget.item.name,
                                    isEditing: widget.item.isEditing,
                                  ),
                                  onCancelPressCallback: () {
                                    updateItemEditing(
                                      box: widget.box,
                                      index: widget.index,
                                      isEditing: false,
                                    );
                                  },
                                  secondaryAction: Transform.scale(
                                    scale: setup.fontSize / 20,
                                    child: Checkbox(
                                      value: widget.item.isSelected,
                                      activeColor: Theme.of(context)
                                          .buttonTheme
                                          .colorScheme!
                                          .background,
                                      onChanged: (newVal) {
                                        updateItemSelected(
                                          box: widget.box,
                                          index: widget.index,
                                          isSelected: newVal!,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: EditableTextWithTextField(
                                    index: widget.index,
                                    onTapCallback: () {
                                      textEditingController.text =
                                          widget.item.name;

                                      updateItemEditing(
                                        box: widget.box,
                                        index: widget.index,
                                        isEditing: true,
                                      );
                                    },
                                    editableObject: EditableObject(
                                      name: widget.item.name,
                                      isEditing: widget.item.isEditing,
                                    ),
                                    controller: textEditingController,
                                    onSubmittedCallback: (newVal) {
                                      commitItemEditChanges(
                                        box: widget.box,
                                        index: widget.index,
                                        context: context,
                                        newName: textEditingController.text,
                                      );
                                    },
                                  ),
                                ),
                                //DELETE BUTTON WITH CHECK (IF EDITING)
                                CheckButtonWithSecondaryAction(
                                  editableObject: EditableObject(
                                    name: widget.item.name,
                                    isEditing: widget.item.isEditing,
                                  ),
                                  onCheckPressCallback: () {
                                    commitItemEditChanges(
                                      box: widget.box,
                                      index: widget.index,
                                      context: context,
                                      newName: textEditingController.text,
                                    );
                                  },
                                  secondaryAction: Transform.scale(
                                    scale: setup.fontSize / 20,
                                    child: PopupMenuButton(
                                      onSelected: (value) {
                                        switch (value) {
                                          case "delete":
                                            deleteItemFromBox(widget.index);
                                            break;
                                          case "openDetails":
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ItemDetailsScreen(
                                                  index: widget.index,
                                                ),
                                              ),
                                            );
                                            break;
                                          default:
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem(
                                            value: 'openDetails',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Open details'),
                                                Icon(
                                                  Icons.open_in_new,
                                                  size: 22,
                                                  color: Theme.of(context)
                                                      .buttonTheme
                                                      .colorScheme!
                                                      .background,
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Delete'),
                                                Icon(Icons.delete_outline,
                                                    color: Colors.red[400]),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: hasImages(widget.item.images)
                    ? setup.isListView
                        ? setup.itemSize - 3
                        : setup.itemSize + 37.5
                    : setup.isListView
                        ? setup.itemSize - 3
                        : setup.itemSize - 12,
                left: 25,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: setup.isListView
                          ? constraints.smallest.height + 10
                          : constraints.smallest.height + 20,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.item.tagPointer == null
                            ? 0
                            : widget.item.tagPointer!.length,
                        itemBuilder: (context, tagIndex) {
                          final tag = tagBox
                              .getAt(widget.item.tagPointer![tagIndex]) as Tag;

                          List<String> words = tag.label.split(' ');
                          String initials = words.map((word) => word[0]).join();

                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: badges.Badge(
                              badgeStyle: badges.BadgeStyle(
                                shape: badges.BadgeShape.circle,
                                badgeColor: Color(tag.color),
                                padding: const EdgeInsets.all(5),
                              ),
                              badgeContent: !setup.isListView
                                  ? Text(initials,
                                      style:
                                          const TextStyle(color: Colors.white))
                                  : const Text(""),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailsScreen(index: widget.index),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
