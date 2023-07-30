import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
 Widget build(BuildContext context) {
    return Container(
      color: Colors.black45, // Dimmed background color
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

