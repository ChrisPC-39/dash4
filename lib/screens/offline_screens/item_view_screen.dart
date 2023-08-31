import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:dash4/globals.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:badges/badges.dart' as badges;

import '../../database/item.dart';
import '../../database/setup.dart';
import '../../database/tag.dart';
import 'offline_methods/image_storage_methods.dart';
import 'offline_methods/list_methods.dart';
import 'sub_screens/list_screen.dart';

class ItemViewScreen extends StatefulWidget {
  final Setup setup;

  const ItemViewScreen({super.key, required this.setup});

  @override
  State<ItemViewScreen> createState() => _ItemViewScreenState();
}

class _ItemViewScreenState extends State<ItemViewScreen> {
  TextEditingController searchBarController = TextEditingController();
  List<Uint8List>? cachedImages = [];
  List<bool> isSelected = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < Hive.box(tagBoxName).length; i++) {
      isSelected.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_sharp),
                onPressed: () {},
              ),
              IconButton(
                icon: widget.setup.isListView
                    ? const Icon(Icons.view_list)
                    : const Icon(Icons.grid_view_sharp),
                onPressed: () => setState(() {
                  toggleListView();
                }),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ListScreen(
              searchBar: searchBarController,
              hasCachedImages: cachedImages!.isNotEmpty,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: hasImages(cachedImages),
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          hasImages(cachedImages) ? cachedImages!.length : 0,
                      itemBuilder: (context, index) {
                        final Uint8List image = cachedImages![index];

                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Image.memory(image),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor:
                                            Colors.black.withOpacity(0.25),
                                        onTap: () => showImageDialog(
                                          context: context,
                                          imageBytes: image,
                                          onDelete: () {
                                            cachedImages!.remove(image);

                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                //TAGS (unused - bad UI)
                // SizedBox(
                //   width: double.infinity,
                //   height: 40,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.end,
                //     children: [
                //       IconButton(
                //         icon: const Icon(Icons.keyboard_arrow_right),
                //         onPressed: () {},
                //       ),
                //       ListView.builder(
                //         shrinkWrap: true,
                //         scrollDirection: Axis.horizontal,
                //         itemCount: Hive.box(tagBoxName).length,
                //         itemBuilder: (buildContext, tagIndex) {
                //           final tag =
                //               Hive.box(tagBoxName).getAt(tagIndex) as Tag;
                //
                //           return ChoiceChip(
                //             label: Text(tag.label),
                //             selected: isSelected[tagIndex],
                //             onSelected: (newVal) {
                //               isSelected[tagIndex] = newVal;
                //               setState(() {});
                //             },
                //             backgroundColor: Colors.grey[300],
                //             selectedColor: Color(tag.color),
                //           );
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: const [
                                  Icon(Icons.new_label),
                                  SizedBox(width: 5),
                                  Text("Add tags"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: const [
                                  Icon(Icons.folder_open),
                                  SizedBox(width: 5),
                                  Text("Add section"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: const [
                                  Icon(Icons.upload),
                                  SizedBox(width: 5),
                                  Text("Upload photos"),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (val) {
                            switch (val) {
                              case 0:
                                addSectionToBox(searchBarController, context);
                                break;
                              case 1:
                                uploadFileDialog(
                                  context: context,
                                  galleryPress: () => pickImageFromGallery(),
                                  cameraPress: () => pickImageFromCamera(),
                                  onCancel: () {
                                    setState(() {
                                      cachedImages = [];
                                    });

                                    Navigator.pop(context);
                                  },
                                );
                                break;
                              case 2:
                                selectTagDialog();
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: Colors.grey[100],
                            child: TextField(
                              controller: searchBarController,
                              onChanged: (newVal) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: "Search or add an item...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            if (searchBarController.text.isEmpty) {
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

                            addItemToBox(searchBarController, context);

                            if (!hasImages(cachedImages)) {
                              return;
                            }

                            for (var element in cachedImages!) {
                              storeImage(element, 0);
                            }

                            cachedImages = [];
                          }),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(
                                // Theme.of(context).buttonTheme.colorScheme!.background,
                                Colors.transparent),
                            fixedSize: MaterialStateProperty.all(
                              const Size(55, 55),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.send,
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme!
                                .background,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void selectTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(builder: (context, constraints) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Choose tags"),
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
                            )),
                          ),
                          const SizedBox(width: 15),
                          Text(tag.label),
                        ],
                      ),
                      onChanged: (newVal) {
                        setState(() {
                          isSelected[tagIndex] = newVal!;
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

  Future pickImageFromCamera() async {
    final PickedFile? pickedImage =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);

    if (pickedImage == null) {
      return null;
    }

    Uint8List imageBytes = await pickedImage.readAsBytes();

    cachedImages!.add(imageBytes);

    setState(() {});
  }

  Future pickImageFromGallery() async {
    final List<PickedFile>? pickedImages =
        await ImagePicker.platform.pickMultiImage();

    if (pickedImages == null) {
      return null;
    }

    pickedImages.forEach((element) async {
      Uint8List imageBytes = await element.readAsBytes();

      cachedImages!.add(imageBytes);
    });

    setState(() {});
  }
}
