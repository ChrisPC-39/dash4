import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../database/editable_object.dart';
import '../../database/tag.dart';
import '../../globals.dart';
import '../../widgets/check_button_with_secondary_action.dart';
import '../../widgets/editable_text_with_textfield.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/subscreen_appbar_back.dart';
import 'offline_methods/item_methods.dart';

class AllTagViewScreen extends StatefulWidget {
  const AllTagViewScreen({super.key});

  @override
  State<AllTagViewScreen> createState() => _AllTagViewScreenState();
}

class _AllTagViewScreenState extends State<AllTagViewScreen> {
  TextEditingController searchBarController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: subScreenAppBar(title: "All tags", context: context),
        body: ValueListenableBuilder(
          valueListenable: Hive.box(tagBoxName).listenable(),
          builder: (context, value, _) {
            final tagBox = Hive.box(tagBoxName);

            return Stack(
              children: [
                ListView.builder(
                  itemCount: tagBox.length + 1,
                  itemBuilder: (context, tagIndex) {
                    if(tagIndex == tagBox.length) {
                      return const SizedBox(height: 100);
                    }

                    final tag = tagBox.getAt(tagIndex) as Tag;

                    if (searchBarController.text != "" &&
                        !tag.label.contains(searchBarController.text)) {
                      return const SizedBox(height: 0, width: 0);
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0),
                                  ),
                                  color: Color(tag.color),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: EditableTextWithTextField(
                                  index: tagIndex,
                                  textAlign: TextAlign.start,
                                  editableObject: EditableObject(
                                    name: tag.label,
                                    isEditing: tag.isEditing,
                                  ),
                                  controller: tagTextController,
                                  onTapCallback: () {
                                    tagTextController.text = tag.label;

                                    updateTagEditing(
                                      box: tagBox,
                                      index: tagIndex,
                                      isEditing: true,
                                    );
                                  },
                                  onSubmittedCallback: (newVal) {
                                    commitTagEditChanges(
                                      box: tagBox,
                                      index: tagIndex,
                                      context: context,
                                      newLabel: tagTextController.text,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              CheckButtonWithSecondaryAction(
                                editableObject: EditableObject(
                                  name: tag.label,
                                  isEditing: tag.isEditing,
                                ),
                                onCheckPressCallback: () {
                                  commitTagEditChanges(
                                    box: tagBox,
                                    index: tagIndex,
                                    context: context,
                                    newLabel: tagTextController.text,
                                  );
                                },
                                secondaryAction: IconButton(
                                  icon: const Icon(Icons.color_lens),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SearchBar(
                      leading: Container(),
                      controller: searchBarController,
                      hintText: "Search or add a tag...",
                      onChangedCallback: (String newVal) => setState(() {}),
                      onSendCallback: () => setState(() {
                        if (!validateInputEmpty(
                            context: context, input: searchBarController.text)) {
                          return;
                        }

                        addNewTag(
                          box: tagBox,
                          context: context,
                          //TODO: Update with real color
                          color: Colors.red.value,
                          label: searchBarController.text,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
