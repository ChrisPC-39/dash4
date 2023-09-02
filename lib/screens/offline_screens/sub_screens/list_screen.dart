import 'dart:typed_data';

import 'package:dash4/screens/offline_screens/offline_methods/item_methods.dart';
import 'package:dash4/screens/offline_screens/sub_screens/item_details_screen.dart';
import 'package:dash4/widgets/check_button_with_secondary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:badges/badges.dart' as badges;

import '../../../database/editable_object.dart';
import '../../../database/item.dart';
import '../../../database/setup.dart';
import '../../../globals.dart';
import '../../../widgets/editable_text_with_textfield.dart';
import '../offline_methods/image_storage_methods.dart';
import '../offline_methods/list_methods.dart';
import '../offline_methods/reorder_methods.dart';
import 'image_screen.dart';

class ListScreen extends StatefulWidget {
  final TextEditingController searchBar;
  final bool hasCachedImages;
  final bool hasCachedTags;

  const ListScreen({
    super.key,
    required this.searchBar,
    required this.hasCachedImages,
    required this.hasCachedTags,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Color? itemColor;
  TextEditingController textEditingController = TextEditingController();
  Setup setup = Setup();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    itemColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: Hive.box(setupBoxName).listenable(),
          builder: (context, Box setupBox, _) {
            setup = Hive.box(setupBoxName).getAt(0);

            return ValueListenableBuilder(
              valueListenable: Hive.box(itemBoxName).listenable(),
              builder: (context, Box itemBox, _) {
                return ReorderableList(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex >= itemBox.length) {
                      return;
                    }

                    onReorderListView(oldIndex, newIndex, itemBox);
                  },
                  onReorderStart: (index) {
                    itemColor = Colors.grey[100];
                  },
                  onReorderEnd: (index) {
                    itemColor = Theme.of(context).cardColor;
                  },
                  itemCount: itemBox.length + 1,
                  itemBuilder: (context, index) {
                    if (index == itemBox.length) {
                      return Container(
                        key: UniqueKey(),
                        height: widget.hasCachedImages
                            ? widget.hasCachedTags
                                ? 235
                                : 200
                            : widget.hasCachedTags
                                ? 135
                                : 100,
                      );
                    }

                    final item = itemBox.getAt(index) as Item;

                    if (widget.searchBar.text != "" &&
                        !item.name.contains(widget.searchBar.text)) {
                      return SizedBox(height: 0, width: 0, key: UniqueKey());
                    }

                    if (widget.searchBar.text != "" &&
                        item.name.contains(widget.searchBar.text) &&
                        !item.isSection &&
                        !item.isVisible) {
                      Item findSection = Item(name: "null", id: -1);

                      for (int i = index; i >= 0; i--) {
                        findSection = itemBox.getAt(i);

                        if (findSection.isSection) {
                          break;
                        }
                      }

                      return Column(
                        key: UniqueKey(),
                        children: [
                          _buildMockSection(findSection),
                          _buildItem(item, index, itemBox),
                        ],
                      );
                    }

                    if (item.isSection) {
                      return _buildSection(item, index, itemBox);
                    }

                    if (item.isVisible) {
                      return _buildItem(item, index, itemBox);
                    }

                    return SizedBox(height: 0, width: 0, key: UniqueKey());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Item item, int index, Box box) {
    return Stack(
      key: ValueKey(item.id),
      children: [
        badges.Badge(
          badgeContent: Container(),
          position: badges.BadgePosition.topStart(top: 0, start: 5),
          showBadge: hasImages(item.images) && setup.isListView,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageScreen(
                  index: index,
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
              index: index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: item.isSelected
                      ? Color.lerp(itemColor, Colors.grey, 0.5)
                      : itemColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Visibility(
                        visible: hasImages(item.images) && !setup.isListView,
                        child: SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hasImages(item.images)
                                ? item.images!.length + 1
                                : 0,
                            itemBuilder: (context, imageIndex) {
                              if (imageIndex == item.images!.length) {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        Container(color: Colors.grey[200]),
                                        const Center(
                                            child: Icon(Icons.open_in_new)),
                                        Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              splashColor: Colors.black
                                                  .withOpacity(0.25),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageScreen(
                                                      index: index,
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

                              final image = item.images![imageIndex];

                              return Row(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(image),
                                      ),
                                      Positioned.fill(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor:
                                                Colors.black.withOpacity(0.25),
                                            onTap: () {
                                              showImageDialog(
                                                context: context,
                                                imageBytes: image,
                                                onDelete: () {
                                                  final List<Uint8List> images =
                                                      item.images!;
                                                  images.remove(image);

                                                  updateItemImages(
                                                    box: Hive.box(itemBoxName),
                                                    index: index,
                                                    images: images,
                                                  );

                                                  setState(() {});
                                                  Navigator.of(context).pop();
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
                          _itemCheckboxCancelIcon(index, item, box),
                          Flexible(
                            child: EditableTextWithTextField(
                              index: index,
                              onTapCallback: () {
                                textEditingController.text = item.name;

                                updateItemEditing(
                                  box: box,
                                  index: index,
                                  isEditing: true,
                                );
                              },
                              editableObject: EditableObject(
                                name: item.name,
                                isEditing: item.isEditing,
                              ),
                              controller: textEditingController,
                              onSubmittedCallback: (newVal) {
                                commitItemEditChanges(
                                  box: box,
                                  index: index,
                                  context: context,
                                  newName: textEditingController.text,
                                );
                              },
                            ),
                          ),
                          _itemDeleteCheckButton(index, item, box),
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
          top: hasImages(item.images)
              ? setup.isListView
                  ? setup.itemSize - 3
                  : setup.itemSize + 37.5
              : setup.isListView
                  ? setup.itemSize - 3
                  : setup.itemSize - 12,
          left: 25,
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              height: setup.isListView
                  ? constraints.smallest.height + 10
                  : constraints.smallest.height + 20,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: item.tags == null ? 0 : item.tags!.length,
                itemBuilder: (context, tagIndex) {
                  final tag = item.tags![tagIndex];
                  final tagColor = item.tagColors![tagIndex];

                  List<String> words = tag.split(' ');
                  String initials = words.map((word) => word[0]).join();

                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: badges.Badge(
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Color(tagColor),
                        padding: const EdgeInsets.all(5),
                      ),
                      badgeContent: !setup.isListView
                          ? Text(initials,
                              style: const TextStyle(color: Colors.white))
                          : const Text(""),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailsScreen(index: index),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSection(Item item, int index, Box box) {
    return Padding(
      key: ValueKey(item.id),
      padding: const EdgeInsets.all(10),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => deleteSectionDialog(
                item,
                box,
                index,
                context,
              ),
              backgroundColor: Colors.red[400]!,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            SlidableAction(
              onPressed: (context) => showEditDialog(context, item, box, index),
              backgroundColor:
                  Theme.of(context).buttonTheme.colorScheme!.background,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ],
        ),
        child: Material(
          child: InkWell(
            onTap: () => handleSectionTap(index, item, box),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_handle,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                _sectionDropIcon(item, context),
                const SizedBox(width: 5),
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: setup.fontSize,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Container(height: 1, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockSection(Item item) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Icon(
            Icons.drag_handle,
            color: Colors.grey,
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.arrow_right,
            size: setup.fontSize + 7,
          ),
          const SizedBox(width: 5),
          Text(
            item.name,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: setup.fontSize,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Container(height: 1, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _itemCheckboxCancelIcon(int index, Item item, Box box) {
    return item.isEditing
        ? IconButton(
            onPressed: () {
              updateItemEditing(
                box: box,
                index: index,
                isEditing: false,
              );
            },
            icon: Icon(Icons.clear, size: setup.fontSize + 7),
          )
        : Transform.scale(
            scale: setup.fontSize / 20,
            child: Checkbox(
              value: item.isSelected,
              activeColor:
                  Theme.of(context).buttonTheme.colorScheme!.background,
              onChanged: (newVal) {
                updateItemSelected(
                  box: box,
                  index: index,
                  isSelected: newVal!,
                );
              },
            ),
          );
  }

  Widget _itemDeleteCheckButton(int index, Item item, Box box) {
    return CheckButtonWithSecondaryAction(
      editableObject: EditableObject(
        name: item.name,
        isEditing: item.isEditing,
      ),
      onCheckPressCallback: () {
        commitItemEditChanges(
          box: box,
          index: index,
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
                deleteItemFromBox(index);
                break;
              case "openDetails":
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsScreen(index: index),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delete'),
                    Icon(Icons.delete_outline, color: Colors.red[400]),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  Widget _sectionDropIcon(Item item, BuildContext context) {
    return item.isVisible
        ? Icon(
            Icons.arrow_drop_down,
            size: setup.fontSize + 7,
          )
        : Icon(
            Icons.arrow_right,
            size: setup.fontSize + 7,
          );
  }
}
