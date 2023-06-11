import 'package:flutter/material.dart';
import 'package:mlritpool/components/search_screen.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/themes/app_theme.dart';

class SearchContainer extends StatefulWidget {
  final Function(MapBoxPlace) setPickupLocation;
  final Function(MapBoxPlace) setDestinationLocation;
  final TextEditingController pickupController;

  const SearchContainer({
    required this.setPickupLocation,
    required this.setDestinationLocation,
    required this.pickupController,
  });

  @override
  _SearchContainerState createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    widget.pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void openSearchScreen(TextEditingController controller,
      Function(MapBoxPlace) setLocation) async {
    final selectedResults = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
    if (selectedResults != null && selectedResults.isNotEmpty) {
      final selectedResult = selectedResults[0];
      controller.text = selectedResult.placeName;
      setLocation(selectedResult);
    }
  }

  void showDriverPassengerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Colors.black),
          ),
          title: const Text(
            'Select Your Role!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Apptheme.thirdColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.button,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    fontSize: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  // Handle driver button press
                  Navigator.of(context).pop();
                  // Navigate to driver screen
                },
                child: const Text('Driver'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.button,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    fontSize: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  minimumSize: const Size(50, 40),
                ),
                onPressed: () {
                  // Handle passenger button press
                  Navigator.of(context).pop();
                  // Navigate to passenger screen
                },
                child: const Text('Passenger'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.conatainer,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.black),
      ),
      constraints: const BoxConstraints(minHeight: 200.0, minWidth: 330.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Where to?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: 300.0,
            height: 60,
            child: GestureDetector(
              onTap: () => openSearchScreen(
                  widget.pickupController,
                  widget.setPickupLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: widget.pickupController,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Pickup',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: 300.0,
            height: 60,
            child: GestureDetector(
              onTap: () => openSearchScreen(
                  _destinationController,
                  widget.setDestinationLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _destinationController,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.button,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 15.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(100, 40),
            ),
            onPressed: () {
              // Handle button press
              showDriverPassengerPopup();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
