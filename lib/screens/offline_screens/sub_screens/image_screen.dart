import 'package:dash4/globals.dart';
import 'package:dash4/widgets/image_gridview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../database/item.dart';
import '../../../widgets/subscreen_appbar_back.dart';

class ImageScreen extends StatefulWidget {
  final int index;

  const ImageScreen({
    super.key,
    required this.index,
  });

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
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
    return Scaffold(
      appBar: subScreenAppBar(title: item.name, context: context),
      body: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: ImageGridView(index: widget.index)
      ),
    );
  }
}