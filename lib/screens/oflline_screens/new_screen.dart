import 'package:dash4/screens/oflline_screens/offline_methods.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../database/category.dart';
import '../../database/item.dart';
import '../../globals.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();

  List<DragAndDropListInterface> _contents = [];

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void buildContents() {
    _contents = [];

    final categoryBox = Hive.box(categoryBoxName);
    final categoryList = categoryBox.values.toList();

    for (int i = 0; i < categoryList.length; i++) {
      final MyCategory category = categoryList[i];

      List<DragAndDropItem> dragAndDropItems = [];

      for (int j = 0; j < category.subItems.length; j++) {
        final Item subItem = category.subItems[j];

        dragAndDropItems.add(
          DragAndDropItem(
            child: Text(subItem.name),
          ),
        );
      }

      if (isMainCategory(category)) {
        _contents.add(DragAndDropList(
          canDrag: false,
          children: dragAndDropItems,
          contentsWhenEmpty: Container(),
        ));
      } else {
        _contents.add(DragAndDropListExpansion(
          listKey: ObjectKey(_contents),
          contentsWhenEmpty: Container(),
          children: dragAndDropItems,
          initiallyExpanded: category.isVisible,
          disableTopAndBottomBorders: true,
          onExpansionChanged: (isExpanded) {
            updateCategoryVisibility(
              box: categoryBox,
              index: i,
              isVisible: isExpanded,
            );
          },
          title: _buildSection(category, i, categoryBox),
        ));
      }
    }
  }

  bool isMainCategory(MyCategory category) {
    return category.id == 0 && category.name == mainCategoryName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    buildContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box(categoryBoxName).listenable(),
        builder: (context, Box categoryBox, _) {
          return DragAndDropLists(
            onItemReorder: (int oldItemIndex, int oldListIndex,
                int newItemIndex, int newListIndex) {
              _onItemReorder(
                oldItemIndex,
                oldListIndex,
                newItemIndex,
                newListIndex,
              );
            },
            onListReorder: (int oldListIndex, int newListIndex) {
              //Prevent the list to be dragged above the MAIN CATEGORY
              if(newListIndex == 0) {
                return;
              }

              _onListReorder(oldListIndex, newListIndex);
            },
            listGhost: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 100.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: const Icon(Icons.add_box),
                ),
              ),
            ),
            children: _contents,
          );
        },
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var box = Hive.box(categoryBoxName);

      final MyCategory oldCategory = box.getAt(oldListIndex);
      var oldList = oldCategory.subItems;
      var removedItem = oldList.removeAt(oldItemIndex);
      box.putAt(
        oldListIndex,
        MyCategory(
          name: oldCategory.name,
          id: oldCategory.id,
          isVisible: oldCategory.isVisible,
          subItems: oldList,
        ),
      );

      final MyCategory newCategory = box.getAt(newListIndex);
      var newList = newCategory.subItems;
      newList.insert(newItemIndex, removedItem);
      box.putAt(
        newListIndex,
        MyCategory(
          name: newCategory.name,
          id: newCategory.id,
          isVisible: newCategory.isVisible,
          subItems: newList,
        ),
      );

      buildContents();
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var box = Hive.box(categoryBoxName);

      var boxAsList = box.values.toList();
      var removedSection = boxAsList.removeAt(oldListIndex);
      boxAsList.insert(newListIndex, removedSection);

      for (int i = 0; i < box.length; i++) {
        box.putAt(i, boxAsList[i]);
      }

      buildContents();
    });
  }

  Widget _buildSection(MyCategory category, int index, Box box) {
    return Slidable(
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // box.deleteAt(index);
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
                      TextEditingController(text: category.name);

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
                          updateCategoryName(
                            box: box,
                            index: index,
                            newTitle: textEditingController.text,
                          );
                          buildContents();
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
      child: Row(
        children: [
          Text(
            category.name,
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
    );
  }
}
