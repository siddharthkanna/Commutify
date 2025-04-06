import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import '../../models/vehicle_modal.dart';
import '../../services/vehicle_api.dart';

class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({Key? key}) : super(key: key);
  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;
  late TextEditingController _fuelTypeController;
  late TextEditingController _fuelEfficiencyController;
  
  final _formKey = GlobalKey<FormState>();
  
  String _selectedVehicleType = 'Car';
  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Bus', 'Truck', 'Other'];
  
  int _capacity = 4;
  final List<int> _capacityOptions = [1, 2, 3, 4, 5, 6, 7, 8];
  
  List<String> _selectedFeatures = [];
  final List<String> _availableFeatures = [
    'AC', 
    'Music System', 
    'GPS', 
    'Leather Seats', 
    'Sunroof', 
    'Bluetooth', 
    'Child Seat', 
    'Wheelchair Access'
  ];
  
  bool _isSubmitting = false;
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _colorController = TextEditingController();
    _fuelTypeController = TextEditingController();
    _fuelEfficiencyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _fuelTypeController.dispose();
    _fuelEfficiencyController.dispose();
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
                
                SizedBox(height: screenHeight * 0.02),
                
                // Capacity Selector
                Text(
                  'Capacity (number of passengers)',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Apptheme.noir.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Apptheme.mist.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _capacityOptions.length,
                    itemBuilder: (context, index) {
                      final capacity = _capacityOptions[index];
                      final isSelected = capacity == _capacity;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _capacity = capacity;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Apptheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              capacity.toString(),
                              style: TextStyle(
                                color: isSelected ? Apptheme.surface : Apptheme.noir.withOpacity(0.7),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Toggle for Advanced Options
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAdvancedOptions = !_showAdvancedOptions;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _showAdvancedOptions 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                        color: Apptheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _showAdvancedOptions 
                            ? 'Hide Advanced Options' 
                            : 'Show Advanced Options',
                        style: TextStyle(
                          color: Apptheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Advanced Options (conditionally visible)
                if (_showAdvancedOptions) ...[
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Make and Model (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _makeController,
                          decoration: InputDecoration(
                            labelText: 'Make',
                            hintText: 'E.g., Honda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          decoration: InputDecoration(
                            labelText: 'Model',
                            hintText: 'E.g., Civic',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Year and Color (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: InputDecoration(
                            labelText: 'Year',
                            hintText: 'E.g., 2022',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: InputDecoration(
                            labelText: 'Color',
                            hintText: 'E.g., Blue',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Fuel Type and Efficiency (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _fuelTypeController,
                          decoration: InputDecoration(
                            labelText: 'Fuel Type',
                            hintText: 'E.g., Petrol',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _fuelEfficiencyController,
                          decoration: InputDecoration(
                            labelText: 'Fuel Efficiency',
                            hintText: 'E.g., 20 km/l',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Features
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Apptheme.noir.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableFeatures.map((feature) {
                      final isSelected = _selectedFeatures.contains(feature);
                      return FilterChip(
                        label: Text(feature),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFeatures.add(feature);
                            } else {
                              _selectedFeatures.remove(feature);
                            }
                          });
                        },
                        backgroundColor: Apptheme.mist.withOpacity(0.1),
                        selectedColor: Apptheme.primary.withOpacity(0.2),
                        checkmarkColor: Apptheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Apptheme.primary : Apptheme.noir.withOpacity(0.7),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
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
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSubmitting = true;
                                });
                                
                                final newVehicle = Vehicle(
                                  vehicleName: _nameController.text.trim(),
                                  vehicleNumber: _numberController.text.trim(),
                                  vehicleType: _selectedVehicleType,
                                  capacity: _capacity,
                                  color: _colorController.text.isEmpty ? null : _colorController.text,
                                  make: _makeController.text.isEmpty ? null : _makeController.text,
                                  model: _modelController.text.isEmpty ? null : _modelController.text,
                                  year: _yearController.text.isEmpty ? null : _yearController.text,
                                  fuelType: _fuelTypeController.text.isEmpty ? null : _fuelTypeController.text,
                                  fuelEfficiency: _fuelEfficiencyController.text.isEmpty 
                                      ? null 
                                      : _fuelEfficiencyController.text,
                                  features: _selectedFeatures.isEmpty ? null : _selectedFeatures,
                                );
                                
                                final success = await VehicleApi.createVehicle(newVehicle);
                                
                                if (mounted) {
                                  Navigator.of(context).pop({
                                    'vehicle': newVehicle,
                                    'success': success
                                  });
                                }
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
