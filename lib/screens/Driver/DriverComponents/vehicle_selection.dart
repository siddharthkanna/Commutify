import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/models/vehicle_modal.dart';
import 'package:commutify/services/vehicle_api.dart';

class VehicleSelection extends ConsumerStatefulWidget {
  Vehicle selectedVehicle;
  final Function(Vehicle) updateSelectedVehicle;

  VehicleSelection({
    Key? key,
    required this.selectedVehicle,
    required this.updateSelectedVehicle,
  }) : super(key: key);

  @override
  _VehicleSelectionState createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends ConsumerState<VehicleSelection> {
  List<Vehicle> vehicleList = [];
  bool isLoading = true;
  bool hasInitialSelection = false;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future fetchVehicles() async {
    vehicleList = await VehicleApi.fetchVehicles();

    setState(() {
      if (!hasInitialSelection && vehicleList.isNotEmpty) {
        widget.updateSelectedVehicle(vehicleList[0]);
        hasInitialSelection = true;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Apptheme.primary),
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    if (vehicleList.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Apptheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_car_outlined,
                color: Colors.black54,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                'No vehicles found',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a vehicle in your profile',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Apptheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Apptheme.mist.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select a vehicle',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: vehicleList.length > 2 ? 225 : 125,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemCount: vehicleList.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleList[index];
                final isSelected = widget.selectedVehicle.vehicleNumber == vehicle.vehicleNumber;
                
                return _buildVehicleCard(vehicle, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVehicleCard(Vehicle vehicle, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.updateSelectedVehicle(vehicle);
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Apptheme.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Apptheme.primary : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Apptheme.primary.withOpacity(0.2) 
                      : Apptheme.mist.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.vehicleType),
                  color: isSelected ? Apptheme.primary : Colors.black54,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.vehicleName,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Apptheme.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.vehicleNumber,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Apptheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
      case 'motorcycle':
        return Icons.motorcycle;
      case 'bus':
        return Icons.directions_bus;
      case 'truck':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }
}
