import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../database/editable_object.dart';
import '../database/setup.dart';
import '../globals.dart';

class EditableTextWithTextField extends StatefulWidget {
  final int index;
  final EditableObject editableObject;
  final TextEditingController controller;
  final Function() onTapCallback;
  final Function(String newVal) onSubmittedCallback;
  final TextAlign textAlign;

  const EditableTextWithTextField({
    super.key,
    required this.index,
    required this.editableObject,
    required this.controller,
    required this.onSubmittedCallback,
    required this.onTapCallback,
    this.textAlign = TextAlign.center,
  });

  @override
  State<EditableTextWithTextField> createState() => _EditableTextWithTextFieldState();
}

class _EditableTextWithTextFieldState extends State<EditableTextWithTextField> {
  Setup setup = Setup();

  @override
  void initState() {
    super.initState();

    setup = Hive.box(setupBoxName).getAt(0) as Setup;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapCallback,
      child: widget.editableObject.isEditing
          ? TextField(
        autofocus: true,
        textAlign: widget.textAlign,
        controller: widget.controller,
        style: TextStyle(fontSize: setup.fontSize),
        onSubmitted: (value) => widget.onSubmittedCallback(value),
      )
          : Text(
        widget.editableObject.name,
        textAlign: widget.textAlign,
        style: TextStyle(fontSize: setup.fontSize),
      ),
    );
  }
}
