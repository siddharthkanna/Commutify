import 'package:flutter/material.dart';

class PassengerScreen extends StatefulWidget {
  @override
  _PassengerScreenState createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  int _selectedOption = 0;

  void _onOptionChanged(int value) {
    setState(() {
      _selectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Ride Type:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const  Text('Immediate'),
                  selected: _selectedOption == 0,
                  onSelected: (value) {
                    _onOptionChanged(0);
                  },
                ),
                const SizedBox(width: 16.0),
                ChoiceChip(
                  label: Text('Scheduled'),
                  selected: _selectedOption == 1,
                  onSelected: (value) {
                    _onOptionChanged(1);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Available Rides:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            // Add your code to display the available rides based on the selected option
          ],
        ),
      ),
    );
  }
}
