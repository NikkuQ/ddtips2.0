import 'package:flutter/material.dart';

class TipItem {
  final Key key;
  String text;
  final FocusNode focusNode;
  final TextEditingController controller;

  TipItem({required this.text})
    : key = UniqueKey(),
      focusNode = FocusNode(),
      controller = TextEditingController(text: text);

  void dispose() {
    focusNode.dispose();
    controller.dispose();
  }
}
