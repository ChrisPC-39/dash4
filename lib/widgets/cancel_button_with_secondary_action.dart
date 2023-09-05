import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../database/editable_object.dart';
import '../database/setup.dart';
import '../globals.dart';

class CancelButtonWithSecondaryAction extends StatefulWidget {
  final EditableObject editableObject;
  final Function() onCancelPressCallback;
  final Widget secondaryAction;

  const CancelButtonWithSecondaryAction({
    super.key,
    required this.editableObject,
    required this.onCancelPressCallback,
    required this.secondaryAction,
  });

  @override
  State<CancelButtonWithSecondaryAction> createState() =>
      _CancelButtonWithSecondaryActionState();
}

class _CancelButtonWithSecondaryActionState
    extends State<CancelButtonWithSecondaryAction> {
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
      icon: Icon(Icons.clear, size: setup.fontSize + 7),
      onPressed: widget.onCancelPressCallback,
    )
        : widget.secondaryAction;
  }
}
