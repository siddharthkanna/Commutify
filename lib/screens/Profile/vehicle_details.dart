import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/screens/Profile/add_vehicle.dart';
import 'package:commutify/screens/Profile/edit_vehicle.dart';
import 'package:commutify/services/user_api.dart';
import 'package:commutify/services/vehicle_api.dart';
import '../../models/vehicle_modal.dart';
import 'package:flutter/material.dart';

class VehicleDetails extends ConsumerStatefulWidget {
  const VehicleDetails({Key? key}) : super(key: key);

  @override
  ConsumerState<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends ConsumerState<VehicleDetails> {
  List<Vehicle> vehicles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVehicleData();
  }

  Future<void> fetchVehicleData() async {
    setState(() {
      isLoading = true;
    });

    final fetchedVehicles = await VehicleApi.fetchVehicles();

    setState(() {
      vehicles = fetchedVehicles;
      isLoading = false;
    });
  }

  Future<void> addVehicle() async {
    final newVehicle = await showDialog<Vehicle>(
      context: context,
      builder: (BuildContext context) {
        return const AddVehicleDialog();
      },
    );

    if (newVehicle != null) {
      setState(() => isLoading = true);
      
      try {
        final isSuccess = await VehicleApi.createVehicle(
          newVehicle.vehicleName,
          newVehicle.vehicleNumber,
          newVehicle.vehicleType,
        );

        if (isSuccess) {
          await fetchVehicleData();
          if (mounted) {
            Snackbar.showSnackbar(context, "Vehicle added successfully!");
          }
        } else {
          if (mounted) {
            Snackbar.showSnackbar(context, "Failed to add the vehicle!");
          }
        }
      } catch (e) {
        if (mounted) {
          Snackbar.showSnackbar(context, "An error occurred. Please try again.");
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> editVehicle(Vehicle vehicle) async {
    final updatedVehicle = await showDialog<Vehicle>(
      context: context,
      builder: (BuildContext context) {
        return EditVehicleDialog(vehicle: vehicle);
      },
    );

    if (updatedVehicle != null) {
      setState(() => isLoading = true);
      
      try {
        await VehicleApi.updateVehicle(
          updatedVehicle.id!,
          updatedVehicle.vehicleName,
          updatedVehicle.vehicleNumber,
          updatedVehicle.vehicleType,
        );
        
        await fetchVehicleData();
        if (mounted) {
          Snackbar.showSnackbar(context, "Vehicle updated successfully!");
        }
      } catch (e) {
        if (mounted) {
          Snackbar.showSnackbar(context, "Failed to update the vehicle: $e");
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Apptheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              
              try {
                final isSuccess = await VehicleApi.deleteVehicle(vehicleId);

                if (isSuccess) {
                  await fetchVehicleData();
                  if (mounted) {
                    Snackbar.showSnackbar(context, "Vehicle deleted successfully");
                  }
                } else {
                  if (mounted) {
                    Snackbar.showSnackbar(context, "Failed to delete the vehicle");
                  }
                }
              } catch (e) {
                if (mounted) {
                  Snackbar.showSnackbar(context, "An error occurred. Please try again.");
                }
              } finally {
                if (mounted) {
                  setState(() => isLoading = false);
                }
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Apptheme.primary,
        iconTheme: const IconThemeData(color: Apptheme.surface),
        title: const Text(
          'Vehicle Details',
          style: TextStyle(
            color: Apptheme.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: EdgeInsets.all(screenSize.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Vehicles',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.06,
                      color: Apptheme.noir,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage the vehicles you use for commuting',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      color: Apptheme.noir.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Vehicle list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Apptheme.primary))
                  : vehicles.isEmpty
                      ? _buildEmptyState(screenSize)
                      : _buildVehicleList(screenSize),
            ),
          ],
        ),
      ),
      floatingActionButton: vehicles.isEmpty || isLoading
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              child: FloatingActionButton.extended(
                onPressed: isLoading ? null : addVehicle,
                backgroundColor: Apptheme.primary,
                foregroundColor: Apptheme.surface,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Apptheme.surface,
                  size: 22,
                ),
                label: const Text(
                  'Add Vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Apptheme.surface,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.06),
            decoration: BoxDecoration(
              color: Apptheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: screenSize.width * 0.15,
              color: Apptheme.primary,
            ),
          ),
          SizedBox(height: screenSize.width * 0.04),
          Text(
            "No vehicles found",
            style: TextStyle(
              fontSize: screenSize.width * 0.05,
              fontWeight: FontWeight.w600,
              color: Apptheme.noir,
            ),
          ),
          SizedBox(height: screenSize.width * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
            child: Text(
              "Add your first vehicle to start commuting with others",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                color: Apptheme.noir.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(height: screenSize.width * 0.08),
          ElevatedButton.icon(
            onPressed: addVehicle,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Your First Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.primary,
              foregroundColor: Apptheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.width * 0.03,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(Size screenSize) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.width * 0.02,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(
            vertical: screenSize.width * 0.025,
            horizontal: screenSize.width * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Apptheme.mist.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Apptheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getVehicleIcon(vehicle.vehicleType),
                        color: Apptheme.primary,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.vehicleName,
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Apptheme.noir,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Apptheme.mist.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vehicle.vehicleNumber,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.035,
                                color: Apptheme.noir.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vehicle.vehicleType,
                            style: TextStyle(
                              fontSize: screenSize.width * 0.035,
                              color: Apptheme.noir.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Apptheme.mist.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Apptheme.primary,
                              size: 20,
                            ),
                            onPressed: () => editVehicle(vehicle),
                            tooltip: 'Edit',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => deleteVehicle(vehicle.id!),
                            tooltip: 'Delete',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  IconData _getVehicleIcon(String vehicleType) {
    final type = vehicleType.toLowerCase();
    if (type.contains('car')) {
      return Icons.directions_car_outlined;
    } else if (type.contains('bike') || type.contains('motorcycle')) {
      return Icons.motorcycle_outlined;
    } else if (type.contains('bus')) {
      return Icons.directions_bus_outlined;
    } else if (type.contains('truck')) {
      return Icons.local_shipping_outlined;
    } else {
      return Icons.commute_outlined;
    }
  }
}
