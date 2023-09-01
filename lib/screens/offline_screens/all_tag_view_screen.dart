import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../globals.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/subscreen_appbar_back.dart';

class AllTagViewScreen extends StatefulWidget {
  const AllTagViewScreen({super.key});

  @override
  State<AllTagViewScreen> createState() => _AllTagViewScreenState();
}

class _AllTagViewScreenState extends State<AllTagViewScreen> {
  TextEditingController searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subScreenAppBar(title: "All tags", context: context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(tagBoxName).listenable(),
        builder: (context, value, _) {
          return Stack(
            children: [
              ListView.builder(
                itemCount: Hive.box(tagBoxName).length,
                itemBuilder: (context, tagIndex) {
                  return Container();
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
                    onChangedCallback: (String newVal) {},
                    onSendCallback: () {},
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
