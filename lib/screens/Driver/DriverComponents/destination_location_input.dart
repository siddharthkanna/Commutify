import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/models/map_box_place.dart';

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
    return SizedBox(
      height: 55,
      child: TextFormField(
        readOnly: true,
        controller: destinationLocationController,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Apptheme.ivory,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          labelText: 'Destination',
        ),
      ),
    );
  }
}
