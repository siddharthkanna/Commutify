import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/screens/Driver/DriverComponents/destination_location_input.dart';
import 'package:commutify/screens/Driver/DriverComponents/pickup_location_input.dart';
import 'package:commutify/screens/Driver/DriverComponents/mode_switch.dart';
import 'package:commutify/screens/Driver/DriverComponents/scheduled_mode_section.dart';
import 'package:commutify/screens/Driver/DriverComponents/vehicle_selection.dart';
import 'package:commutify/screens/Driver/DriverComponents/seating_capacity_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/screens/Driver/Ride_Publish.dart';
import 'package:commutify/services/ride_api.dart';
import '../../providers/auth_provider.dart';
import '../../models/vehicle_modal.dart';

class DriverScreen extends ConsumerStatefulWidget {
  MapBoxPlace? pickupLocation;
  MapBoxPlace? destinationLocation;

  DriverScreen({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  bool immediateMode = true;
  bool scheduledMode = false;
  late Vehicle selectedVehicle =
      Vehicle(vehicleName: '', vehicleNumber: '', vehicleType: '');

  int selectedCapacity = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int price = 0;
  bool isRidePublishing = false;

  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickupLocationController.text = widget.pickupLocation?.placeName ?? '';
    destinationLocationController.text =
        widget.destinationLocation?.placeName ?? '';
    selectedTime = TimeOfDay.now();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    pickupLocationController.dispose();
    destinationLocationController.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      immediateMode = !immediateMode;
      scheduledMode = !scheduledMode;
    });
  }

  void incrementPrice() {
    setState(() {
      price = price + 10;
    });
  }

  void decrementPrice() {
    setState(() {
      if (price > 0) {
        price = price - 10;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void switchLocations() {
    setState(() {
      final tempLocation = widget.pickupLocation;
      widget.pickupLocation = widget.destinationLocation;
      widget.destinationLocation = tempLocation;

      pickupLocationController.text = widget.pickupLocation?.placeName ?? '';
      destinationLocationController.text =
          widget.destinationLocation?.placeName ?? '';
    });
  }

  void updateSelectedVehicle(Vehicle newValue) {
    setState(() {
      selectedVehicle = newValue;
    });
  }

  void updateSelectedCapacity(int newValue) {
    setState(() {
      selectedCapacity = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final authService = ref.read(authProvider);
    String? uid = authService.getCurrentUser()?.id;

    // Calculate responsive button sizes
    final buttonWidth = screenSize.width * 0.7;
    final buttonHeight = screenSize.width * 0.14;

    Future<void> publishRide() async {
      setState(() {
        isRidePublishing = true;
      });
      final Map<String, dynamic> rideData = {
        'driverId': uid,
        'pickupLocation': [
          {
            'latitude': widget.pickupLocation?.latitude,
            'longitude': widget.pickupLocation?.longitude,
            'placeName': widget.pickupLocation?.placeName,
          }
        ],
        'destinationLocation': [
          {
            'latitude': widget.destinationLocation?.latitude,
            'longitude': widget.destinationLocation?.longitude,
            'placeName': widget.destinationLocation?.placeName,
          }
        ],
        'immediateMode': immediateMode,
        'scheduledMode': scheduledMode,
        'selectedVehicle': {
          'vehicleName': selectedVehicle.vehicleName,
          'vehicleNumber': selectedVehicle.vehicleNumber,
          'vehicleType': selectedVehicle.vehicleType
        },
        'selectedCapacity': selectedCapacity,
        'selectedDate':
            selectedDate.toIso8601String(), // Convert DateTime to String
        'selectedTime': selectedTime.format(context),
        'price': price,
      };

      final isRidePublished = await RideApi.publishRide(rideData);
      setState(() {
        isRidePublishing = false;
      });

      if (isRidePublished) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RidePublished()),
        );
      } else {
        Snackbar.showSnackbar(
            context, 'Error while publishing the ride! Please try again.');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Apptheme.mist,
        elevation: 1,
        iconTheme: const IconThemeData(color: Apptheme.noir),
        title: const Text(
          'Publish Your Ride',
          style: TextStyle(
              color: Apptheme.noir, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Apptheme.mist,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 25,
            ),
            PickupLocationInput(
              pickupLocation: widget.pickupLocation,
              pickupLocationController: pickupLocationController,
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 50,
                height: 30,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: ShapeDecoration(
                          color: Apptheme.ivory,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 0.50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -9,
                      top: -9,
                      child: IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: () {
                          switchLocations();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DestinationLocationInput(
              destinationLocation: widget.destinationLocation,
              destinationLocationController: destinationLocationController,
            ),
            const SizedBox(height: 20),
            ModeSwitch(
              immediateMode: immediateMode,
              scheduledMode: scheduledMode,
              toggleMode: toggleMode,
            ),
            if (scheduledMode)
              ScheduledModeSection(
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                selectDate: _selectDate,
                selectTime: _selectTime,
              ),
            VehicleSelection(
              selectedVehicle: selectedVehicle,
              updateSelectedVehicle: updateSelectedVehicle,
            ),
            SeatingCapacitySelection(
              selectedCapacity: selectedCapacity,
              updateSelectedCapacity: updateSelectedCapacity,
            ),
            const SizedBox(height: 30),
            const Text(
              'SET THE PRICE:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    decrementPrice();
                  },
                  icon: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Apptheme.ivory),
                    child: const Icon(Icons.remove),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Rs. $price',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  width: 15,
                ),
                IconButton(
                  onPressed: () {
                    incrementPrice();
                  },
                  icon: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Apptheme.ivory,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            Container(
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: screenSize.width * 0.09),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight),
                  backgroundColor: Apptheme.noir,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 0.04),
                  ),
                ),
                onPressed: isRidePublishing ? null : publishRide,
                child: isRidePublishing
                    ? const Loader()
                    : const Text(
                        'Proceed',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
