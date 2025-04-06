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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Apptheme.error.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Apptheme.error.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.5),
                bottomLeft: Radius.circular(14.5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Apptheme.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.location_on_outlined,
                  color: Apptheme.error,
                  size: 18,
                ),
              ],
            ),
          ),
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: destinationLocationController,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Enter destination location',
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Outfit',
                ),
                labelText: destinationLocationController.text.isEmpty ? null : 'To',
                labelStyle: TextStyle(
                  color: Apptheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Outfit',
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
