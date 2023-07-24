import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/screens/Driver/Ride_Publish.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/destination_location_input.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/pickup_location_input.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/mode_switch.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/scheduled_mode_section.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/vehicle_selection.dart';
import 'package:mlritpool/screens/Driver/DriverComponents/seating_capacity_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

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
  late String selectedVehicle = '';
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

  void updateSelectedVehicle(String newValue) {
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
    final authService = ref.read(authProvider);
    String? uid = authService.getCurrentUser()?.uid;

    Future<void> _publishRide() async {
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
        'selectedVehicle': selectedVehicle,
        'selectedCapacity': selectedCapacity,
        'selectedDate':
            selectedDate.toIso8601String(), // Convert DateTime to String
        'selectedTime': selectedTime.format(context),
        'price': price,
        'userRole': 'driver',
      };

      final isRidePublished = await publishRide(rideData);
      setState(() {
        isRidePublishing = false;
      });

      if (isRidePublished) {
        // Ride published successfully
        print('Ride published successfully');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RidePublished()),
        );
        print(rideData);
      } else {
        // Handle error case
        print('Failed to publish ride');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Apptheme.fourthColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Apptheme.primaryColor),
        title: const Text(
          'DRIVER',
          style: TextStyle(
              color: Apptheme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Apptheme.fourthColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: Apptheme.thirdColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 0.50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -9, // Adjust the left offset as needed
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
              uid: uid,
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
                        shape: BoxShape.circle, color: Apptheme.thirdColor),
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
                      color: Apptheme.thirdColor,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Container(
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Apptheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: isRidePublishing
                    ? null // Disable button while publishing
                    : _publishRide,
                // ... (existing code)
                child: isRidePublishing
                    ? const Loader() // Show progress indicator while publishing
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
