import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import '../../models/vehicle_modal.dart';

class EditVehicleDialog extends StatefulWidget {
  final Vehicle vehicle;

  EditVehicleDialog({required this.vehicle});

  @override
  _EditVehicleDialogState createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends State<EditVehicleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle.vehicleName);
    _numberController =
        TextEditingController(text: widget.vehicle.vehicleNumber);
    _typeController = TextEditingController(text: widget.vehicle.vehicleType);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Apptheme.ivory,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      title: Text(
        'Edit Vehicle',
        style: TextStyle(
          fontSize: screenWidth * 0.05,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Vehicle Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: 'Vehicle Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final updatedVehicle = Vehicle(
                id: widget.vehicle.id,
                vehicleName: _nameController.text,
                vehicleNumber: _numberController.text,
                vehicleType: _typeController.text,
              );
              Navigator.of(context).pop(updatedVehicle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
            ),
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
