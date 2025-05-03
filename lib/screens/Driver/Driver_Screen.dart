// ignore_for_file: file_names, prefer_const_constructors

import 'package:commutify/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/error.dart';
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
import 'package:commutify/services/map_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/vehicle_modal.dart';

// ignore: must_be_immutable
class DriverScreen extends ConsumerStatefulWidget {
  MapBoxPlace? pickupLocation;
  MapBoxPlace? destinationLocation;

  DriverScreen({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> with SingleTickerProviderStateMixin {
  bool immediateMode = true;
  bool scheduledMode = false;
  late Vehicle selectedVehicle =
      Vehicle(vehicleName: '', vehicleNumber: '', vehicleType: '');

  int selectedCapacity = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int price = 0;
  bool isRidePublishing = false;
  bool isCalculatingRoute = false;
  
  // Route estimation data
  double? estimatedDistance;
  double? estimatedDuration;
  bool hasRouteEstimate = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuint),
      ),
    );
    
    _animationController.forward();
    
    // Calculate route estimation after the UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateRouteEstimation();
    });
  }

  @override
  void didUpdateWidget(DriverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recalculate if locations change
    if (oldWidget.pickupLocation != widget.pickupLocation || 
        oldWidget.destinationLocation != widget.destinationLocation) {
      calculateRouteEstimation();
    }
  }

  Future<void> calculateRouteEstimation() async {
    if (widget.pickupLocation == null || widget.destinationLocation == null) {
      return;
    }
    
    setState(() {
      isCalculatingRoute = true;
      hasRouteEstimate = false;
    });
    
    try {
      final routeDetails = await MapService.getRouteDetails(
        widget.pickupLocation,
        widget.destinationLocation,
      );
      
      setState(() {
        estimatedDistance = routeDetails['distance'];
        estimatedDuration = routeDetails['duration'];
        hasRouteEstimate = true;
        isCalculatingRoute = false;
        
        // Suggest a recommended price based on distance
        // Only update price if it's still the default (0)
        if (price == 0 && estimatedDistance != null && estimatedDistance! > 0) {
          // Simple formula: base price (50) + 10 per kilometer
          // Round to nearest 10
          final calculatedPrice = 50 + (estimatedDistance! * 10).toInt();
          price = (calculatedPrice ~/ 10) * 10; // Round to nearest 10
        }
      });
    } catch (e) {
      debugPrint('Error calculating route: $e');
      setState(() {
        isCalculatingRoute = false;
      });
    }
  }

  @override
  void dispose() {
    pickupLocationController.dispose();
    destinationLocationController.dispose();
    _animationController.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Apptheme.primary,
              onPrimary: Colors.white,
              surface: Apptheme.surface,
            ),
            dialogBackgroundColor: Apptheme.mist,
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Apptheme.primary,
              onPrimary: Colors.white,
              surface: Apptheme.surface,
            ),
            dialogBackgroundColor: Apptheme.mist,
          ),
          child: child!,
        );
      },
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
          
      // Reset route estimates
      hasRouteEstimate = false;
    });
    
    // Recalculate route after switch
    calculateRouteEstimation();
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
    final buttonWidth = screenSize.width * 0.85;
    const buttonHeight = 60.0;

    Future<void> publishRide() async {
      // Validate required fields
      if (selectedVehicle.vehicleNumber.isEmpty) {
        Snackbar.showSnackbar(
          context,
          'Please select a vehicle before publishing the ride.',
        );
        return;
      }

      setState(() {
        isRidePublishing = true;
      });

      // If we don't have route details yet, calculate them now
      if (!hasRouteEstimate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calculating route details...'),
            duration: Duration(seconds: 2),
            backgroundColor: Apptheme.primary,
          ),
        );

        try {
          final routeDetails = await MapService.getRouteDetails(
            widget.pickupLocation,
            widget.destinationLocation,
          );
          
          estimatedDistance = routeDetails['distance'];
          estimatedDuration = routeDetails['duration'];
          
          if (estimatedDistance == 0 || estimatedDuration == 0) {
            setState(() {
              isRidePublishing = false;
            });
            
            Snackbar.showSnackbar(
              context,
              'Could not calculate a valid route between these locations. Please try different locations.',
            );
            return;
          }
        } catch (e) {
          setState(() {
            isRidePublishing = false;
          });
          
          Snackbar.showSnackbar(
            context,
            'Error calculating route. Please check your internet connection and try again.',
          );
          return;
        }
      }

      // Show a loading indicator with publishing message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publishing your ride...'),
          duration: Duration(seconds: 2),
          backgroundColor: Apptheme.primary,
        ),
      );

      // Prepare ride data with the obtained route details
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
        'selectedDate': selectedDate.toIso8601String(),
        'selectedTime': _combineDateTime(selectedDate, selectedTime).toIso8601String(),
        'price': price,
        'pricePerKm': 0,
        'estimatedDistance': estimatedDistance,
        'estimatedDuration': estimatedDuration,
        'isRecurring': false,
        'recurringDays': [],
        'notes': '',
        'waypoints': [],
      };

      try {
      final isRidePublished = await RideApi.publishRide(rideData);
        
      setState(() {
        isRidePublishing = false;
      });

      if (isRidePublished) {
        Navigator.push(
          context,
            MaterialPageRoute(
              builder: (context) => RidePublished(
                estimatedDistance: estimatedDistance,
                estimatedDuration: estimatedDuration,
              ),
            ),
        );
      } else {
          NotificationUtils.showError(context, 'Error while publishing the ride! Please try again.');
        }
      } catch (e) {
        setState(() {
          isRidePublishing = false;
        });
        
        NotificationUtils.showError(context, 'Error while publishing the ride! Please try again.');
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Publish Your Ride',
          style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Apptheme.primary.withOpacity(0.9),
                Apptheme.primary.withOpacity(0.0),
              ],
            ),
                          ),
                        ),
                      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(Apptheme.primary, Apptheme.background, 0.85)!,
              Apptheme.background,
                  ],
                ),
              ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.05, 
                kToolbarHeight + MediaQuery.of(context).padding.top + 20, 
                screenSize.width * 0.05, 
                20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Card with visual connector
                  _buildRouteCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Mode selection section
                  ScaleTransition(
                    scale: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('RIDE MODE'),
                        const SizedBox(height: 8),
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Vehicle section
                  ScaleTransition(
                    scale: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('VEHICLE DETAILS'),
                        const SizedBox(height: 8),
            VehicleSelection(
              selectedVehicle: selectedVehicle,
              updateSelectedVehicle: updateSelectedVehicle,
            ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Seating capacity section
                  ScaleTransition(
                    scale: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('SEATING CAPACITY'),
                        const SizedBox(height: 8),
            SeatingCapacitySelection(
              selectedCapacity: selectedCapacity,
              updateSelectedCapacity: updateSelectedCapacity,
            ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Price section
                  ScaleTransition(
                    scale: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('RIDE PRICE'),
                        const SizedBox(height: 8),
                        _buildPriceSelector(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Proceed button
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeOutQuart),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Apptheme.primary,
                              Color.lerp(Apptheme.primary, Apptheme.secondary, 0.3)!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Apptheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(buttonWidth, buttonHeight),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isRidePublishing ? null : publishRide,
                          child: isRidePublishing
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 3,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
            const Text(
                                      'Publish Ride',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRouteCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Apptheme.primary,
                  Color.lerp(Apptheme.primary, Apptheme.secondary, 0.2)!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.route,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "YOUR ROUTE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Route content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PickupLocationInput(
                  pickupLocation: widget.pickupLocation,
                  pickupLocationController: pickupLocationController,
                ),
                _buildRouteConnector(),
                DestinationLocationInput(
                  destinationLocation: widget.destinationLocation,
                  destinationLocationController: destinationLocationController,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: switchLocations,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Apptheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Apptheme.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Icon(
                          Icons.swap_vert,
                          size: 18,
                          color: Apptheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Swap locations',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Apptheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Route estimation preview
                if (widget.pickupLocation != null && widget.destinationLocation != null)
                  _buildRouteEstimation(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRouteConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.only(left: 22),
      child: SizedBox(
        height: 30,
        child: Stack(
          children: [
            // Vertical line
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: Apptheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Animated dots
            ...List.generate(
              3,
              (index) => TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 1500 + (index * 300)),
                curve: Curves.easeInOut,
                builder: (context, double value, child) {
                  return Positioned(
                    left: -3,
                    top: value * 30 - 6, // Moving down
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Apptheme.primary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRouteEstimation() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Apptheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Apptheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: isCalculatingRoute
          ? Center(
              child: const Column(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Apptheme.primary),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Calculating route...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Outfit',
                      color: Apptheme.primary,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEstimationDetail(
                  icon: Icons.route,
                  value: hasRouteEstimate 
                    ? '${estimatedDistance?.toStringAsFixed(1) ?? "0"} km'
                    : 'Unknown',
                  label: 'Distance',
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: Apptheme.primary.withOpacity(0.2),
                ),
                _buildEstimationDetail(
                  icon: Icons.timer,
                  value: hasRouteEstimate 
                    ? '${estimatedDuration?.toStringAsFixed(0) ?? "0"} min'
                    : 'Unknown',
                  label: 'Duration',
                ),
              ],
            ),
    );
  }
  
  Widget _buildEstimationDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Apptheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: Apptheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
                color: Apptheme.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Outfit',
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Apptheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
              letterSpacing: 1.2,
              color: Apptheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Apptheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Apptheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Set your price',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              if (hasRouteEstimate && estimatedDistance != null)
                Tooltip(
                  message: 'Suggested price based on distance (₹50 base + ₹10/km)',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Apptheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: Apptheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Auto-suggested',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit',
                            color: Apptheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceButton(
                icon: Icons.remove,
                onPressed: price > 0 ? decrementPrice : null,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Apptheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit',
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          price.toString(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                            color: Apptheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'per passenger',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Outfit',
                          color: Colors.black54,
                        ),
                      ),
                      if (hasRouteEstimate && estimatedDistance != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '• ${(price / estimatedDistance!).toStringAsFixed(1)}₹/km',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Outfit',
                            color: Apptheme.secondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              _buildPriceButton(
                icon: Icons.add,
                onPressed: incrementPrice,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: onPressed == null 
          ? Colors.grey.shade200 
          : Apptheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: onPressed == null ? Colors.grey : Apptheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
