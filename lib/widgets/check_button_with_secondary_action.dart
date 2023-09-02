import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../database/editable_object.dart';
import '../database/setup.dart';
import '../globals.dart';

class CheckButtonWithSecondaryAction extends StatefulWidget {
  final EditableObject editableObject;
  final Function() onCheckPressCallback;
  final Widget secondaryAction;

  const CheckButtonWithSecondaryAction({
    super.key,
    required this.editableObject,
    required this.onCheckPressCallback,
    required this.secondaryAction,
  });

  @override
  State<CheckButtonWithSecondaryAction> createState() =>
      _CheckButtonWithSecondaryActionState();
}

class _CheckButtonWithSecondaryActionState
    extends State<CheckButtonWithSecondaryAction> {
  Setup setup = Setup();

  @override
  void initState() {
    super.initState();

    setup = Hive.box(setupBoxName).getAt(0) as Setup;
  }

  @override
  Widget build(BuildContext context) {
    return widget.editableObject.isEditing
        ? IconButton(
            icon: Icon(Icons.check, size: setup.fontSize + 7),
            onPressed: widget.onCheckPressCallback,
          )
        : widget.secondaryAction;
  }
}
