import 'dart:typed_data';

import 'package:flutter/material.dart';

bool hasImages(List? list) {
  return list != null && list.isNotEmpty;
}

void showImageDialog({
  required BuildContext context,
  required Uint8List imageBytes,
  required Function() onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => onDelete(),
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[400],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                // child: const Text("Back"),
                icon: Icon(
                  Icons.close_fullscreen,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          Expanded(
            child: InteractiveViewer(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(imageBytes),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget buildEmptyTile(double height, double width, Function() onPressed) {
  return SizedBox(
    height: height,
    width: width,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(color: Colors.grey[200]),
          const Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.black.withOpacity(0.25),
                onTap: () => onPressed(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void uploadFileDialog({
  required BuildContext context,
  required Function() galleryPress,
  required Function() cameraPress,
  required Function() onCancel,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.upload),
            SizedBox(width: 5),
            Text('Upload photos'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async => galleryPress(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.photo),
                    SizedBox(width: 5),
                    Text('Upload from gallery'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('or'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async => cameraPress(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 5),
                    Text('Upload from camera'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => onCancel(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          )
        ],
      );
    },
  );
}
