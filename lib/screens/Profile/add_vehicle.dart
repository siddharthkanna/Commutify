import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import '../../models/vehicle_modal.dart';

class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({Key? key}) : super(key: key);
  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _typeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Apptheme.ivory,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Text('New Vehicle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Vehicle Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TextFormField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: 'Vehicle Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TextFormField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          ElevatedButton(
            onPressed: () {
              final newVehicle = Vehicle(
                vehicleName: _nameController.text,
                vehicleNumber: _numberController.text,
                vehicleType: _typeController.text,
              );
              Navigator.of(context).pop(newVehicle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
