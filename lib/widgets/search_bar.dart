import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final Widget leading;
  final TextEditingController controller;
  final Function(String newVal) onChangedCallback;
  final Function() onSendCallback;
  final String hintText;

  const SearchBar({
    super.key,
    required this.leading,
    required this.controller,
    required this.onChangedCallback,
    required this.onSendCallback,
    required this.hintText,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              widget.leading,
              Expanded(
                child: Card(
                  elevation: 0,
                  color: Colors.grey[100],
                  child: TextField(
                    controller: widget.controller,
                    onChanged: (newVal) => widget.onChangedCallback(newVal),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
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
                onPressed: widget.onSendCallback,
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  fixedSize: MaterialStateProperty.all(const Size(55, 55)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                ),
                child: Icon(
                  Icons.send,
                  color: Theme.of(context).buttonTheme.colorScheme!.background,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
