import 'package:flutter/material.dart';

class DriverDetailScreen extends StatefulWidget {
  @override
  _DriverDetailScreenState createState() => _DriverDetailScreenState();
}

enum RideOption {
  Immediate,
  Scheduled,
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  RideOption _selectedOption = RideOption.Immediate;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _seatsAvailable = 1;
  double _pricePerSeat = 0.0;
  VehicleType _vehicleType = VehicleType.Bike;

  void _onOptionChanged(RideOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ride Option:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            ToggleButtons(
              isSelected: [
                _selectedOption == RideOption.Immediate,
                _selectedOption == RideOption.Scheduled,
              ],
              onPressed: (index) {
                final option = RideOption.values[index];
                _onOptionChanged(option);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Immediate'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Scheduled'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_selectedOption == RideOption.Scheduled) ...[
              const Text(
                'Scheduled Date:',
                style: TextStyle(fontSize: 18.0),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate != null
                      ? _selectedDate.toString().split(' ')[0]
                      : 'Select Date',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Departure Time:',
                style: TextStyle(fontSize: 18.0),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(
                  _selectedTime != null
                      ? _selectedTime.toString()
                      : 'Select Time',
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            const Text(
              'Vehicle Type:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            ToggleButtons(
              isSelected: [
                _vehicleType == VehicleType.Bike,
                _vehicleType == VehicleType.Car,
              ],
              onPressed: (index) {
                final type = VehicleType.values[index];
                setState(() {
                  _vehicleType = type;
                  if (type == VehicleType.Bike) {
                    _seatsAvailable = 1;
                  }
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Bike'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Car'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Seats Available:',
              style: TextStyle(fontSize: 18.0),
            ),
            DropdownButtonFormField<int>(
              value: _seatsAvailable,
              onChanged: (newValue) {
                setState(() {
                  _seatsAvailable = newValue!;
                });
              },
              items: List.generate(
                _vehicleType == VehicleType.Bike ? 1 : 6,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text((index + 1).toString()),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Price per Seat:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextFormField(
              onChanged: (newValue) {
                setState(() {
                  _pricePerSeat = double.tryParse(newValue) ?? 0.0;
                });
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter price per seat',
              ),
            ),
            const SizedBox(height: 16.0),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle proceed button press
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}

enum VehicleType {
  Bike,
  Car,
}
