import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class MyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Apptheme.secondaryColor,
      child: const Center(
        child:  Text(
          'My Activity',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
