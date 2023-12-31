import 'package:flutter/material.dart';

class Bio extends StatelessWidget {
  const Bio(this.text);

  final String? text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
