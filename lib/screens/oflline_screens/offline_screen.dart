import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../database/item.dart';
import '../../globals.dart';
import 'offline_methods.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  Color? itemColor;
  TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    itemColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box(itemBoxName).listenable(),
        builder: (context, Box itemBox, _) {
          return ReorderableList(
            physics: const BouncingScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              onReorder(oldIndex, newIndex, itemBox);
            },
            onReorderStart: (index) {
              itemColor = Colors.grey[100];
            },
            onReorderEnd: (index) {
              itemColor = Colors.white;
            },
            itemCount: itemBox.length,
            itemBuilder: (context, index) {
              final item = itemBox.getAt(index) as Item;

              if (item.isSection) {
                return _buildSection(item, index, itemBox);
              }

              if(item.isVisible) {
                return _buildItem(item, index, itemBox);
              }

              return Container(key: UniqueKey());
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(Item item, int index, Box box) {
    return Card(
      key: ValueKey(item.id),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: itemColor,
            borderRadius: BorderRadius.circular(10.0),
            // Other decorations for the container
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                item.isEditing
                    ? IconButton(
                        onPressed: () {
                          updateItemEditing(
                            box: box,
                            index: index,
                            isEditing: false,
                          );
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : Checkbox(
                        value: item.isSelected,
                        activeColor: Theme.of(context)
                            .buttonTheme
                            .colorScheme!
                            .background,
                        onChanged: (newVal) {
                          updateItemSelected(
                            box: box,
                            index: index,
                            isSelected: newVal!,
                          );
                        },
                      ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      textEditingController.text = item.name;

                      updateItemEditing(
                        box: box,
                        index: index,
                        isEditing: true,
                      );
                    },
                    child: item.isEditing
                        ? TextField(
                            autofocus: true,
                            textAlign: TextAlign.center,
                            controller: textEditingController,
                            onSubmitted: (value) {
                              updateItemEditing(
                                box: box,
                                index: index,
                                isEditing: false,
                              );

                              updateItemName(
                                box: box,
                                index: index,
                                newTitle: textEditingController.text,
                              );
                            },
                          )
                        : Text(
                            item.name,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                item.isEditing
                    ? IconButton(
                        onPressed: () {
                          updateItemEditing(
                            box: box,
                            index: index,
                            isEditing: false,
                          );

                          updateItemName(
                            box: box,
                            index: index,
                            newTitle: textEditingController.text,
                          );
                        },
                        icon: const Icon(Icons.check),
                      )
                    : IconButton(
                        onPressed: () {
                          box.deleteAt(index);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(Item item, int index, Box box) {
    return Padding(
      key: ValueKey(item.id),
      padding: const EdgeInsets.all(10),
      child: Slidable(
        startActionPane: ActionPane(
          extentRatio: 0.2,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                box.deleteAt(index);
              },
              backgroundColor: Colors.red[400]!,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController textEditingController =
                        TextEditingController(text: item.name);

                    return AlertDialog(
                      title: const Text('Enter Text'),
                      content: TextField(
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
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .background,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor:
                  Theme.of(context).buttonTheme.colorScheme!.background,
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),
          ],
        ),
        child: Material(
          child: InkWell(
            onTap: () {
              setState(() {
                final startSection = index;
                updateItemVisibility(
                  box: box,
                  index: startSection,
                  isVisible: !item.isVisible,
                );

                for (int i = startSection + 1; i < box.length; i++) {
                  final subItem = box.getAt(i) as Item;

                  if (subItem.isSection) {
                    break;
                  }

                  updateItemVisibility(
                    box: box,
                    index: i,
                    isVisible: !subItem.isVisible,
                  );
                }
              });
            },
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
                item.isVisible
                    ? const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.arrow_right,
                        color: Colors.grey,
                      ),
                const SizedBox(width: 5),
                Text(
                  item.name + item.subItems.toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
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
}
