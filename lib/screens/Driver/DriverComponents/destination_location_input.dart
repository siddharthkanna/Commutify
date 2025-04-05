import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/models/map_box_place.dart';

class DestinationLocationInput extends StatelessWidget {
  final MapBoxPlace? destinationLocation;
  final TextEditingController destinationLocationController;

  const DestinationLocationInput({
    Key? key,
    required this.destinationLocation,
    required this.destinationLocationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final textFieldHeight = screenHeight * 0.07;
    final fontSize = mediaQuery.textScaleFactor * 14.0;
    final borderRadius = BorderRadius.circular(screenHeight * 0.02);
    final padding = EdgeInsets.symmetric(
        vertical: screenHeight * 0.015, horizontal: screenHeight * 0.02);

    return SizedBox(
      height: textFieldHeight,
      child: TextFormField(
        readOnly: true,
        controller: destinationLocationController,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Apptheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:borderRadius,
          ),
          labelText: 'Destination',
        ),
      ),
    );
  }
}
