import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../database/item.dart';
import '../globals.dart';
import '../screens/offline_screens/offline_methods/image_storage_methods.dart';

class ImageGridView extends StatefulWidget {
  final int index;

  const ImageGridView({super.key, required this.index});

  @override
  State<ImageGridView> createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  late List<Uint8List> images = [];
  Item item = Item(name: "View all photos", id: -1);

  @override
  void initState() {
    super.initState();

    if (widget.index >= 0) {
      item = Hive.box(itemBoxName).getAt(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(itemBoxName).listenable(),
      builder: (context, itemBox, _) {
        if(hasImages(item.images)) {
          final Item selectedItem = itemBox.getAt(widget.index);
          images = selectedItem.images!;
        }

        return MasonryGridView.builder(
          shrinkWrap: true,
          gridDelegate:
          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: images.length + 1,
          itemBuilder: (context, index) {
            if (index == images.length) {
              return LayoutBuilder(builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = width;

                return buildEmptyTile(height, width, () {
                  uploadFileDialog(
                    context: context,
                    galleryPress: () async {
                      await pickImageFromGallery(widget.index);

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    cameraPress: () async {
                      await pickImageFromCamera(widget.index);

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                });
              });
            }

            final imageBytes = images[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.memory(imageBytes),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.black.withOpacity(0.25),
                        onTap: () =>
                            showImageDialog(
                              context: context,
                              imageBytes: imageBytes,
                              onDelete: () {
                                images.remove(imageBytes);

                                updateItemImages(
                                  box: Hive.box(itemBoxName),
                                  index: widget.index,
                                  images: images,
                                );

                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future pickImageFromCamera(int index) async {
    images = [];
    final PickedFile? pickedImage =
    await ImagePicker.platform.pickImage(source: ImageSource.camera);

    if (pickedImage == null) {
      return null;
    }

    images.add(await pickedImage.readAsBytes());

    if (!hasImages(images)) {
      return;
    }

    for (var element in images) {
      storeImage(element, index);
    }
  }

  Future pickImageFromGallery(int index) async {
    images = [];
    final List<PickedFile>? pickedImages =
    await ImagePicker.platform.pickMultiImage();

    if (pickedImages == null) {
      return null;
    }

    for (var element in pickedImages) {
      images.add(await element.readAsBytes());
    }

    if (!hasImages(images)) {
      return;
    }

    for (var element in images) {
      storeImage(element, index);
    }
  }
}