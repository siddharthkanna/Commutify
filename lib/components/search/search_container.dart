import 'package:flutter/material.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/components/search/search_screen.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/screens/Driver/Driver_Screen.dart';
import 'package:commutify/screens/Passenger/passengerScreen.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:flutter/services.dart';

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

class _SearchContainerState extends State<SearchContainer> with SingleTickerProviderStateMixin {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  MapBoxPlace? selectedPickupLocation;
  MapBoxPlace? selectedDestinationLocation;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setInitialPickupLocation();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    
    _animationController.forward();
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
    _animationController.dispose();
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
    HapticFeedback.lightImpact();
    final selectedResults = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
    if (selectedResults != null && selectedResults.isNotEmpty) {
      HapticFeedback.selectionClick();
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
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: Apptheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.06,
                    color: Apptheme.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you driving or looking for a ride?',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    color: Apptheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRoleButton(
                      context: context,
                      icon: Icons.drive_eta,
                      label: 'Driver',
                      onPressed: () {
                        Navigator.pop(context);
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
                    ),
                    _buildRoleButton(
                      context: context,
                      icon: Icons.airline_seat_recline_normal,
                      label: 'Passenger',
                      onPressed: () {
                        Navigator.pop(context);
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleButton({
    required BuildContext context, 
    required IconData icon, 
    required String label, 
    required VoidCallback onPressed
  }) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: screenSize.width * 0.3,
      height: screenSize.width * 0.32,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Apptheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Apptheme.primary,
          padding: EdgeInsets.symmetric(
            vertical: screenSize.width * 0.03,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenSize.width * 0.1,
              color: Apptheme.surface,
            ),
            SizedBox(height: screenSize.width * 0.02),
            Text(
              label,
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                fontWeight: FontWeight.w600,
                color: Apptheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 25,
              offset: const Offset(0, 5),
            ),
          ],
          color: Apptheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        constraints: BoxConstraints(
            minHeight: screenSize.width * 0.55,
            minWidth: screenSize.width * 0.91),
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Apptheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: Apptheme.primary,
                    size: screenSize.width * 0.06,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                Text(
                  'Where to?',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Apptheme.text,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.width * 0.05),
            
            // Locations container
            Container(
              decoration: BoxDecoration(
                color: Apptheme.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.all(screenSize.width * 0.03),
              child: Column(
                children: [
                  // Pickup field
                  _buildInputField(
                    controller: _pickupController,
                    label: 'Pickup',
                    icon: Icons.circle_outlined,
                    iconColor: Apptheme.success,
                    onTap: () => openSearchScreen(_pickupController, widget.setPickupLocation),
                    context: context,
                    isFirst: true,
                  ),
                  
                  // Connector line
                  Padding(
                    padding: EdgeInsets.only(left: screenSize.width * 0.056),
                    child: Row(
                      children: [
                        Column(
                          children: List.generate(
                            3,
                            (index) => Container(
                              width: 2,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: Apptheme.primary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Destination field
                  _buildInputField(
                    controller: _destinationController,
                    label: 'Destination',
                    icon: Icons.location_on,
                    iconColor: Apptheme.error,
                    onTap: () => openSearchScreen(_destinationController, widget.setDestinationLocation),
                    context: context,
                    isFirst: false,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenSize.width * 0.04),
            
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: screenSize.width * 0.13,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.primary,
                  foregroundColor: Apptheme.surface,
                  elevation: 0,
                  shadowColor: Apptheme.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (_pickupController.text.isEmpty) {
                    ErrorDialog.showErrorDialog(
                        context, 'Please enter your pickup location');
                  } else if (_destinationController.text.isEmpty) {
                    ErrorDialog.showErrorDialog(
                        context, 'Please enter your destination location');
                  } else if (_pickupController.text ==
                      _destinationController.text) {
                    ErrorDialog.showErrorDialog(
                        context, 'Pickup and destination cannot be the same');
                  } else {
                    showDriverPassengerPopup();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      color: Apptheme.surface,
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      'Find Ride',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Apptheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Function onTap,
    required BuildContext context,
    required bool isFirst,
  }) {
    final screenSize = MediaQuery.of(context).size;
    
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenSize.width * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.02,
          vertical: screenSize.width * 0.02,
        ),
        decoration: BoxDecoration(
          color: controller.text.isNotEmpty ? Apptheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: controller.text.isNotEmpty
              ? Border.all(color: iconColor.withOpacity(0.2), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: Apptheme.text,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                    hintStyle: TextStyle(
                      color: Apptheme.textSecondary,
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
            if (controller.text.isNotEmpty && !isFirst)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Apptheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Apptheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
