import 'package:flutter/material.dart';
import 'package:mlritpool/components/search/search_screen.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/screens/Driver/Driver_Screen.dart';
import 'package:mlritpool/screens/Passenger/passengerScreen.dart';
import 'package:mlritpool/themes/app_theme.dart';

class SearchContainer extends StatefulWidget {
  final Function(MapBoxPlace) setPickupLocation;
  final Function(MapBoxPlace) setDestinationLocation;
  final MapBoxPlace? currentLocation;

  const SearchContainer(
      {Key? key,
      required this.setPickupLocation,
      required this.setDestinationLocation,
      required this.currentLocation})
      : super(key: key);

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  MapBoxPlace? selectedPickupLocation;
  MapBoxPlace? selectedDestinationLocation;

  @override
  void initState() {
    super.initState();
    _setInitialPickupLocation();
  }

  @override
  void didUpdateWidget(covariant SearchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocation != oldWidget.currentLocation) {
      selectedPickupLocation = widget.currentLocation;
      _pickupController.text = widget.currentLocation!.placeName;
      widget.setPickupLocation(widget.currentLocation!);
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _setInitialPickupLocation() {
    if (widget.currentLocation != null) {
      setState(() {
        selectedPickupLocation = widget.currentLocation;
        _pickupController.text = widget.currentLocation!.placeName;
      });
      widget.setPickupLocation(widget.currentLocation!);
    }
  }

  void openSearchScreen(
    TextEditingController controller,
    Function(MapBoxPlace) setLocation,
  ) async {
    final selectedResults = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
    if (selectedResults != null && selectedResults.isNotEmpty) {
      final selectedResult = selectedResults[0];
      controller.text = selectedResult.placeName;
      setLocation(selectedResult);

      if (controller == _pickupController) {
        setState(() {
          selectedPickupLocation = selectedResult;
        });
      } else if (controller == _destinationController) {
        setState(() {
          selectedDestinationLocation = selectedResult;
        });
      }
    }
  }

  void showDriverPassengerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Select Your Role!',
          ),
          backgroundColor: Apptheme.thirdColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.primaryColor,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverScreen(
                        pickupLocation: selectedPickupLocation,
                        destinationLocation: selectedDestinationLocation,
                      ),
                    ),
                  );
                },
                child: const Text('Driver'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.primaryColor,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassengerScreen(),
                    ),
                  );
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: Apptheme.conatainer,
        borderRadius: BorderRadius.circular(15.0),
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
              onTap: () =>
                  openSearchScreen(_pickupController, widget.setPickupLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _pickupController,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.normal),
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
          const SizedBox(height: 12.0),
          SizedBox(
            width: 300.0,
            height: 60,
            child: GestureDetector(
              onTap: () => openSearchScreen(
                  _destinationController, widget.setDestinationLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _destinationController,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.normal),
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
            height: 10.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.primaryColor,
              textStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Outfit',
                fontSize: 15.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(100, 42),
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
