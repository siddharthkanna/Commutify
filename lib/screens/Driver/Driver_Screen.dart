import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/screens/Driver/Ride_Publish.dart';

class DriverScreen extends StatefulWidget {
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

class _DriverScreenState extends State<DriverScreen> {
  bool immediateMode = true;
  bool scheduledMode = false;
  String selectedVehicle = 'Car';
  int selectedCapacity = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int price = 0;

  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickupLocationController.text = widget.pickupLocation?.placeName ?? '';
    destinationLocationController.text =
        widget.destinationLocation?.placeName ?? '';
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

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 55,
              child: TextFormField(
                readOnly: true,
                controller: pickupLocationController,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Apptheme.thirdColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: 'Pickup',
                ),
              ),
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
            SizedBox(
              height: 55,
              child: TextFormField(
                readOnly: true,
                controller: destinationLocationController,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Apptheme.thirdColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: 'Destination',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        scheduledMode ? Apptheme.button : Apptheme.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        scheduledMode ? 'SCHEDULED' : 'IMMEDIATE',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Switch(
                  value: scheduledMode,
                  onChanged: (value) {
                    toggleMode();
                  },
                  activeColor: Apptheme.button,
                  inactiveThumbColor: Apptheme.primaryColor,
                ),
              ],
            ),

            if (scheduledMode) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled Date: ${selectedDate.toString().substring(0, 10)}',
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
                    child: const Text('Select Date'),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scheduled Time: ${selectedTime.format(context)}'),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
            ],
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
                color: Apptheme.thirdColor,
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
              child: DropdownButton<String>(
                value: selectedVehicle,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedVehicle = newValue!;
                  });
                },
                items: <String>['Car', 'Motorcycle', 'Truck', 'Van']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0,
                          right: 50.0), // Add padding to adjust the space
                      child: Text(
                        value,
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
            const SizedBox(height: 30),
            const Text(
              'SEATING CAPACITY:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              width: 200,
              height: 45,
              decoration: BoxDecoration(
                color: Apptheme.thirdColor,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54
                        .withOpacity(0.5), // Specify the shadow color
                    spreadRadius: 1, // Specify the spread radius
                    blurRadius: 5, // Specify the blur radius
                    offset: const Offset(0, 3), // Specify the offset
                  ),
                ],
              ),
              child: DropdownButton<int>(
                value: selectedCapacity,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedCapacity = newValue!;
                  });
                },
                items: <int>[1, 2, 3, 4, 5]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 100.0),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 32.0,
                underline: SizedBox(),
                dropdownColor: Apptheme.thirdColor,
              ),
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
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Apptheme.thirdColor),
                    child: Icon(Icons.remove),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  '\Rs. $price',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 15,
                ),
                IconButton(
                  onPressed: () {
                    incrementPrice();
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Apptheme.thirdColor,
                    ),
                    child: Icon(Icons.add),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RidePublished()),
                    );
                    // Handle the "Proceed" button press
                  },
                  child: Text(
                    'Proceed',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Apptheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)))),
            ),
            // Add additional padding at the bottom
          ],
        ),
      ),
    );
  }
}
