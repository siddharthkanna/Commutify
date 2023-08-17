import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/common/error.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/screens/Profile/add_vehicle.dart';
import 'package:mlritpool/screens/Profile/edit_vehicle.dart';
import 'package:mlritpool/services/api_service.dart';
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

    final fetchedVehicles = await ApiService.fetchVehicles();

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
      final isSuccess = await ApiService.createVehicle(
        newVehicle.vehicleName,
        newVehicle.vehicleNumber,
        newVehicle.vehicleType,
      );

      if (isSuccess) {
        fetchVehicleData();
      } else {
        Snackbar.showSnackbar(context, "Failed to add the Vehicle!");
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
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      setState(() {
        vehicles[index] = updatedVehicle;
      });

      await ApiService.updateVehicle(
        updatedVehicle.id!,
        updatedVehicle.vehicleName,
        updatedVehicle.vehicleNumber,
        updatedVehicle.vehicleType,
      );
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final isSuccess = await ApiService.deleteVehicle(vehicleId);

              if (isSuccess) {
                setState(() {
                  vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
                });

                Snackbar.showSnackbar(context, "Vehicle deleted successfully");
              } else {
                Snackbar.showSnackbar(context, "Failed to delete the Vehicle");
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Apptheme.mist,
        iconTheme: const IconThemeData(color: Apptheme.noir),
      ),
      backgroundColor: Apptheme.mist,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Text(
              'Your Vehicles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.075,
              ),
            ),
          ),
          SizedBox(
            height: screenWidth * 0.06,
          ),
          Expanded(
            child: isLoading
                ? const Loader()
                : vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No vehicles found.",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            color: Apptheme.ivory,
                            margin: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.025,
                              horizontal: screenWidth * 0.05,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04),
                            ),
                            child: ListTile(
                              title: Text(vehicle.vehicleName),
                              subtitle: Text(
                                  '${vehicle.vehicleNumber} - ${vehicle.vehicleType}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      editVehicle(vehicle);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      deleteVehicle(vehicle.id!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addVehicle();
        },
        backgroundColor: Apptheme.navy,
        child: const Icon(Icons.add),
      ),
    );
  }
}
