import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:dash4/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isSelected = false;

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
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: Hive.box(tagBoxName).length,
                          itemBuilder: (buildContext, tagIndex) {
                            final tag =
                                Hive.box(tagBoxName).getAt(tagIndex) as Tag;

                            return ChoiceChip(
                              label: Text(tag.label),
                              selected: isSelected,
                              onSelected: (newVal) {
                                isSelected = newVal;
                                setState(() {});
                              },
                              backgroundColor: Colors.grey[300],
                              selectedColor: Color(tag.color),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        PopupMenuButton(
                          itemBuilder: (context) => [
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