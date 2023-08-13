import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlritpool/Themes/app_theme.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/models/vehicle_modal.dart';

class VehicleSelection extends ConsumerStatefulWidget {
  Vehicle selectedVehicle;
  final Function(Vehicle) updateSelectedVehicle;
  String? uid;

  VehicleSelection({
    Key? key,
    required this.selectedVehicle,
    required this.updateSelectedVehicle,
    required this.uid,
  }) : super(key: key);

  @override
  _VehicleSelectionState createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends ConsumerState<VehicleSelection> {
  List<Vehicle> vehicleList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.0.104:3000/auth/vehicles/${widget.uid}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehicleDataList = data['vehicles'] as List<dynamic>;

        setState(() {
          vehicleList = vehicleDataList
              .map((vehicleData) =>
                  Vehicle.fromJson(vehicleData as Map<String, dynamic>))
              .toList();
          widget.selectedVehicle = vehicleList.first;
          isLoading = false;
        });
        print(vehicleList);
      } else if (response.statusCode == 404) {
        // Handle the case where the user is not found
        print('User not found');
        setState(() {
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          'SELECT YOUR VEHICLE:',
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
                color: Colors.black54.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isLoading
              ? Transform.scale(
                  scale: 0.6,
                  child: const CircularProgressIndicator(
                    color: Apptheme.noir,
                    strokeWidth: 3,
                  ),
                )
              : DropdownButton<Vehicle>(
                  value: widget.selectedVehicle,
                  onChanged: (Vehicle? newValue) {
                    widget.updateSelectedVehicle(newValue!);
                  },
                  items: vehicleList
                      .map<DropdownMenuItem<Vehicle>>((Vehicle vehicle) {
                    return DropdownMenuItem<Vehicle>(
                      value: vehicle,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 12.0,
                          right: 50.0,
                        ),
                        child: Text(
                          vehicle
                              .vehicleName, // Adjust this to use the vehicle name
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 32.0,
                  underline: const SizedBox(), // Remove the default underline
                  dropdownColor: Colors.white,
                ),
        ),
      ],
    );
  }
}
