import 'dart:typed_data';

import 'package:dash4/screens/offline_screens/offline_methods/item_methods.dart';
import 'package:dash4/screens/offline_screens/sub_screens/item_details_screen.dart';
import 'package:dash4/widgets/cancel_button_with_secondary_action.dart';
import 'package:dash4/widgets/check_button_with_secondary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:badges/badges.dart' as badges;

import '../../../database/editable_object.dart';
import '../../../database/item.dart';
import '../../../database/setup.dart';
import '../../../database/tag.dart';
import '../../../globals.dart';
import '../../../widgets/editable_text_with_textfield.dart';
import '../../../widgets/item_card.dart';
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
  final tagBox = Hive.box(tagBoxName);
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
                      ItemCard(
                        key: ValueKey(item.id),
                        item: item,
                        index: index,
                        box: itemBox,
                      ),
                    ],
                  );
                }

                if (item.isSection) {
                  return _buildSection(item, index, itemBox);
                }

                if (item.isVisible) {
                  return ItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    box: itemBox,
                  );
                  return _buildItem(item, index, itemBox);
                }

                return SizedBox(height: 0, width: 0, key: UniqueKey());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Item item, int index, Box box) {
    return ItemCard(item: item, index: index, box: box, key: ValueKey(item.id));
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
