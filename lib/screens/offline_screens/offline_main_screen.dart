import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/setup.dart';
import '../../database/tag.dart';
import '../../globals.dart';
import '../../widgets/search_bar.dart';
import 'all_tag_view_screen.dart';
import 'offline_methods/image_storage_methods.dart';
import 'offline_methods/item_methods.dart';
import 'offline_methods/list_methods.dart';
import 'sub_screens/list_screen.dart';

class OfflineMainScreen extends StatefulWidget {
  final Setup setup;

  const OfflineMainScreen({super.key, required this.setup});

  @override
  State<OfflineMainScreen> createState() => _OfflineMainScreenState();
}

class _OfflineMainScreenState extends State<OfflineMainScreen> {
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
              IconButton(
                icon: const Icon(Icons.label),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AllTagViewScreen(),
                    ),
                  );
                },
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
              hasCachedTags: isSelected.contains(true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: Hive.box(tagBoxName).length,
                    itemBuilder: (buildContext, tagIndex) {
                      final tag = Hive.box(tagBoxName).getAt(tagIndex) as Tag;

                      return Visibility(
                        visible: isSelected[tagIndex],
                        child: RawChip(
                          showCheckmark: false,
                          label: Text(
                            tag.label,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          selected: isSelected[tagIndex],
                          onSelected: (newVal) {
                            isSelected[tagIndex] = newVal;
                            setState(() {});
                          },
                          backgroundColor: Colors.grey[300],
                          selectedColor: Color(tag.color),
                        ),
                      );
                    },
                  ),
                ),
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
                SearchBar(
                  leading: _buildSearchBarLeading(),
                  controller: searchBarController,
                  hintText: "Search or add an item...",
                  onChangedCallback: (String newVal) {},
                  onSendCallback: () => setState(() {
                    //Validate input
                    if (!validateInputEmpty(
                        context: context, input: searchBarController.text)) {
                      return;
                    }

                    //Check tags and add the item with tags
                    addNewItemWithTags(
                      isSelected: isSelected,
                      controller: searchBarController,
                      context: context,
                      updateSelectedList: (int index) => setState(() {
                        isSelected[index] = false;
                      }),
                    );

                    //Store images and clear cache
                    addImagesToNewItem(
                      cachedImages: cachedImages,
                      clearCacheCallback: () => cachedImages = [],
                    );
                  }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBarLeading() {
    return PopupMenuButton(
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
            void updateSelected(List<bool> updatedList) {
              setState(() {
                isSelected = updatedList;
              });
            }

            selectTagDialog(
              context,
              isSelected,
              updateSelected,
              () {},
            );
            break;
          default:
            break;
        }
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
