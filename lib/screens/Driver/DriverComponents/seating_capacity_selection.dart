import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class SeatingCapacitySelection extends StatelessWidget {
  final int selectedCapacity;
  final Function(int) updateSelectedCapacity;

  const SeatingCapacitySelection({
    Key? key,
    required this.selectedCapacity,
    required this.updateSelectedCapacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          'SEATING CAPACITY:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          width: 200,
          height: 45,
          decoration: BoxDecoration(
            color: Apptheme.ivory,
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black54
                    .withOpacity(0.5), // Specify the shadow color
                spreadRadius: 1, // Specify the spread radius
                blurRadius: 5, // Specify the blur radius
                offset: const Offset(0, 3), // Specify the offset
              ),
            ],
          ),
          child: DropdownButton<int>(
            value: selectedCapacity,
            onChanged: (int? newValue) {
              updateSelectedCapacity(newValue!);
            },
            items: <int>[1, 2, 3, 4, 5]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 100.0),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
            style:const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 32.0,
            underline: const SizedBox(),
            dropdownColor: Apptheme.ivory,
          ),
        ),
      ],
    );
  }
}
