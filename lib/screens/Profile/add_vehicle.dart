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
  final _formKey = GlobalKey<FormState>();
  
  String _selectedVehicleType = 'Car';
  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Bus', 'Truck', 'Other'];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car_outlined;
      case 'motorcycle':
        return Icons.motorcycle_outlined;
      case 'bus':
        return Icons.directions_bus_outlined;
      case 'truck':
        return Icons.local_shipping_outlined;
      default:
        return Icons.commute_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Apptheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Apptheme.primary,
                      size: 28,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Add New Vehicle',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Apptheme.noir,
                      ),
                    ),
                  ],
                ),
                
                Divider(height: screenHeight * 0.03),
                
                // Vehicle Type Selector
                Text(
                  'Vehicle Type',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Apptheme.noir.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: Apptheme.mist.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vehicleTypes.length,
                    itemBuilder: (context, index) {
                      final type = _vehicleTypes[index];
                      final isSelected = type == _selectedVehicleType;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVehicleType = type;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Apptheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getVehicleIcon(type),
                                color: isSelected ? Apptheme.surface : Apptheme.noir.withOpacity(0.7),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                type,
                                style: TextStyle(
                                  color: isSelected ? Apptheme.surface : Apptheme.noir.withOpacity(0.7),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Vehicle Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Name',
                    hintText: 'E.g., My Honda Civic',
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: Apptheme.primary.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.mist),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.mist),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Vehicle Number
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Number',
                    hintText: 'E.g., ABC123',
                    prefixIcon: Icon(
                      Icons.credit_card_outlined,
                      color: Apptheme.primary.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.mist),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.mist),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Apptheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle number';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: screenHeight * 0.03),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Apptheme.noir.withOpacity(0.7),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSubmitting = true;
                                });
                                
                                final newVehicle = Vehicle(
                                  vehicleName: _nameController.text.trim(),
                                  vehicleNumber: _numberController.text.trim(),
                                  vehicleType: _selectedVehicleType,
                                );
                                
                                Navigator.of(context).pop(newVehicle);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Apptheme.primary,
                        foregroundColor: Apptheme.surface,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Apptheme.surface,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Vehicle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
