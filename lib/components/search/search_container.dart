import 'package:flutter/material.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/components/search/search_screen.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/screens/Driver/Driver_Screen.dart';
import 'package:commutify/screens/Passenger/passengerScreen.dart';
import 'package:commutify/Themes/app_theme.dart';

class SearchContainer extends StatefulWidget {
  final Function(MapBoxPlace) setPickupLocation;
  final Function(MapBoxPlace) setDestinationLocation;
  final MapBoxPlace? currentLocation;

  const SearchContainer({
    Key? key,
    required this.setPickupLocation,
    required this.setDestinationLocation,
    required this.currentLocation,
  }) : super(key: key);

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
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide(width: 1)),
          backgroundColor: Apptheme.ivory,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Your Role!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Apptheme.navy,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Outfit',
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.width * 0.1,
                    ),
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
                    backgroundColor: Apptheme.navy,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Outfit',
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.25,
                      MediaQuery.of(context).size.width * 0.1,
                    ),
                  ),
                  onPressed: () {
                    // Handle passenger button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PassengerScreen(
                          pickupLocation: selectedPickupLocation,
                          destinationLocation: selectedDestinationLocation,
                        ),
                      ),
                    );
                  },
                  child: const Text('Passenger'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate responsive font size and button size based on screen width
    final double fontSize22 = screenSize.width * 0.065;
    final double fontSize14 = screenSize.width * 0.04;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: screenSize.width * 0.015,
            blurRadius: screenSize.width * 0.02,
            offset: const Offset(0, 3),
          ),
        ],
        color: Apptheme.mist,
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        border: Border.all(
          color: Colors.black,
          width: screenSize.width * 0.0025,
        ),
      ),
      constraints: BoxConstraints(
          minHeight: screenSize.width * 0.55,
          minWidth: screenSize.width * 0.91),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          Text(
            'Where to?',
            style: TextStyle(
              fontSize: fontSize22,
              fontWeight: FontWeight.bold,
              color: Apptheme.noir,
            ),
          ),
          SizedBox(height: screenSize.width * 0.035),
          SizedBox(
            width: screenSize.width * 0.84,
            height: screenSize.width * 0.16,
            child: GestureDetector(
              onTap: () =>
                  openSearchScreen(_pickupController, widget.setPickupLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _pickupController,
                  style: TextStyle(
                    fontSize: fontSize14,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Apptheme.ivory,
                    labelText: 'Pickup',
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(screenSize.width * 0.04),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(screenSize.width * 0.04),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenSize.width * 0.03),
          SizedBox(
            width: screenSize.width * 0.84,
            height: screenSize.width * 0.16,
            child: GestureDetector(
              onTap: () => openSearchScreen(
                  _destinationController, widget.setDestinationLocation),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _destinationController,
                  style: TextStyle(
                    fontSize: fontSize14,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    filled: true,
                    fillColor: Apptheme.ivory,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(screenSize.width * 0.04),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(screenSize.width * 0.04),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenSize.width * 0.03),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.navy,
              textStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Outfit',
                fontSize: screenSize.width * 0.04,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenSize.width * 0.04),
              ),
              minimumSize:
                  Size(screenSize.width * 0.25, screenSize.width * 0.1),
            ),
            onPressed: () {
              if (_pickupController.text.isEmpty) {
                ErrorDialog.showErrorDialog(
                    context, 'Please Enter your Pickup location!');
              } else if (_destinationController.text.isEmpty) {
                ErrorDialog.showErrorDialog(
                    context, 'Please Enter your Destination location!');
              } else if (_pickupController.text ==
                  _destinationController.text) {
                ErrorDialog.showErrorDialog(
                    context, 'Pickup and destination cant be same!');
              } else {
                showDriverPassengerPopup();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
