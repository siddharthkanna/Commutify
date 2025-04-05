import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/models/map_box_place.dart';

class PickupLocationInput extends StatelessWidget {
  final MapBoxPlace? pickupLocation;
  final TextEditingController pickupLocationController;

  const PickupLocationInput({
    Key? key,
    required this.pickupLocation,
    required this.pickupLocationController,
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final textFieldHeight = screenHeight * 0.07;
    final fontSize = mediaQuery.textScaleFactor * 14.0;
    final borderRadius = BorderRadius.circular(screenHeight * 0.02);


    return SizedBox(
      height: textFieldHeight,
      child: TextFormField(
        readOnly: true,
        controller: pickupLocationController,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Apptheme.ivory,
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:borderRadius,
          ),
          labelText: 'Pickup',
        ),
      ),
    );
  }
}
