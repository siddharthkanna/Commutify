// ignore_for_file: prefer_const_constructors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/controllers/vehicle_controller.dart';
import 'package:commutify/utils/vehicle_ui_helpers.dart';
import 'package:commutify/services/vehicle_api.dart';
import '../../models/vehicle_modal.dart';
import 'package:flutter/material.dart';

class VehicleDetails extends ConsumerStatefulWidget {
  const VehicleDetails({Key? key}) : super(key: key);

  @override
  ConsumerState<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends ConsumerState<VehicleDetails> with SingleTickerProviderStateMixin {
  List<Vehicle> vehicles = [];
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    fetchVehicleData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchVehicleData() async {
    setState(() {
      isLoading = true;
    });

    final fetchedVehicles = await VehicleApi.fetchVehicles();

    setState(() {
      vehicles = fetchedVehicles;
      isLoading = false;
    });
    
    if (mounted) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> addVehicle() async {
    await VehicleController.addVehicle(
      context,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) {
        fetchVehicleData();
        VehicleController.showSuccessSnackbar(context, message);
      },
      onError: (message) => VehicleController.showErrorSnackbar(context, message),
    );
  }

  Future<void> editVehicle(Vehicle vehicle) async {
    await VehicleController.editVehicle(
      context,
      vehicle,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) {
        fetchVehicleData();
        VehicleController.showSuccessSnackbar(context, message);
      },
      onError: (message) => VehicleController.showErrorSnackbar(context, message),
    );
  }

  Future<void> deleteVehicle(String vehicleId, String vehicleName) async {
    await VehicleController.deleteVehicle(
      context,
      vehicleId,
      vehicleName,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) {
        fetchVehicleData();
        VehicleController.showSuccessSnackbar(context, message);
      },
      onError: (message) => VehicleController.showErrorSnackbar(context, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Apptheme.primary,
        iconTheme: const IconThemeData(color: Apptheme.surface),
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: Apptheme.surface,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (!isLoading && vehicles.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Apptheme.surface,
              ),
              onPressed: fetchVehicleData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: isLoading 
          ? _buildLoadingState()
          : vehicles.isEmpty 
              ? _buildEmptyState(screenSize) 
              : _buildVehicleList(screenSize),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : addVehicle,
        backgroundColor: Apptheme.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Apptheme.surface,
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Apptheme.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            "Loading your vehicles...",
            style: TextStyle(
              color: Apptheme.noir.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.08),
                decoration: BoxDecoration(
                  color: Apptheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  size: screenSize.width * 0.16,
                  color: Apptheme.primary,
                ),
              ),
              SizedBox(height: screenSize.width * 0.06),
              Text(
                "No vehicles yet",
                style: TextStyle(
                  fontSize: screenSize.width * 0.07,
                  fontWeight: FontWeight.w600,
                  color: Apptheme.noir,
                ),
              ),
              SizedBox(height: screenSize.width * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                child: Text(
                  "Add your vehicle to start commuting with others",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: Apptheme.noir.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: screenSize.width * 0.08),
              ElevatedButton.icon(
                onPressed: addVehicle,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.primary,
                  foregroundColor: Apptheme.surface,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.08,
                    vertical: screenSize.width * 0.045,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleList(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.width * 0.05,
        ),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final vehicleColor = VehicleUIHelpers.getVehicleColor(vehicle.vehicleType);
          
          // Use a staggered animation based on item index
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.2;
              final start = delay;
              final end = delay + 0.8;
              
              final opacity = CurvedAnimation(
                parent: _animationController,
                curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), 
                  curve: Curves.easeInOut),
              );
              
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), 
                  curve: Curves.easeOutCubic),
              ));
              
              return FadeTransition(
                opacity: opacity,
                child: SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: screenSize.width * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => editVehicle(vehicle),
                  child: Stack(
                    children: [
                      // Subtle accent background
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: screenSize.width * 0.15,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                vehicleColor.withOpacity(0.04),
                                Colors.white.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Card content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top accent line
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: vehicleColor,
                            ),
                          ),
                          
                          // Main content padding
                          Padding(
                            padding: EdgeInsets.all(screenSize.width * 0.045),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row with vehicle info and actions
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Vehicle icon with soft shadow
                                    Hero(
                                      tag: 'vehicle_icon_${vehicle.id}',
                                      child: Container(
                                        width: screenSize.width * 0.14,
                                        height: screenSize.width * 0.14,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: vehicleColor.withOpacity(0.15),
                                              blurRadius: 8,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: vehicleColor.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              VehicleUIHelpers.getVehicleIcon(vehicle.vehicleType),
                                              color: vehicleColor,
                                              size: screenSize.width * 0.06,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenSize.width * 0.03),
                                    
                                    // Vehicle info column
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Vehicle name with ellipsis
                                            Hero(
                                              tag: 'vehicle_name_${vehicle.id}',
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Text(
                                                  vehicle.vehicleName,
                                                  style: TextStyle(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black.withOpacity(0.85),
                                                    letterSpacing: -0.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(height: 6),
                                            
                                            // Vehicle number with tag styling
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.04),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                vehicle.vehicleNumber,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black.withOpacity(0.6),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    // Status indicator badge
                                    if (vehicle.isActive)
                                      Container(
                                        margin: EdgeInsets.only(top: 8, left: 6, right: 0),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: vehicle.isActive
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: vehicle.isActive
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: vehicle.isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              vehicle.isActive ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: vehicle.isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Action menu
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        popupMenuTheme: PopupMenuThemeData(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.black.withOpacity(0.45),
                                          size: 22,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            editVehicle(vehicle);
                                          } else if (value == 'delete') {
                                            deleteVehicle(vehicle.id!, vehicle.vehicleName);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, 
                                                  size: 18, 
                                                  color: vehicleColor,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, 
                                                  size: 18, 
                                                  color: Colors.red.shade400,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 20),
                                
                                // Specs section with better wrapping and spacing
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    // Primary specs first
                                    VehicleUIHelpers.buildSpecChip(
                                      context: context,
                                      icon: Icons.directions_car_filled_outlined,
                                      label: vehicle.vehicleType,
                                      color: vehicleColor,
                                      isPrimary: true,
                                    ),
                                    
                                    // Capacity
                                    if (vehicle.capacity > 0)
                                      VehicleUIHelpers.buildSpecChip(
                                        context: context,
                                        icon: Icons.people_alt_outlined,
                                        label: "${vehicle.capacity} seats",
                                        color: Colors.black54,
                                      ),
                                    
                                    // Make/Model
                                    if (vehicle.make != null || vehicle.model != null)
                                      VehicleUIHelpers.buildSpecChip(
                                        context: context,
                                        icon: Icons.info_outline,
                                        label: [vehicle.make, vehicle.model]
                                            .where((e) => e != null && e.isNotEmpty)
                                            .join(' '),
                                        color: Colors.black54,
                                      ),
                                      
                                    // Year
                                    if (vehicle.year != null)
                                      VehicleUIHelpers.buildSpecChip(
                                        context: context,
                                        icon: Icons.calendar_today_outlined,
                                        label: vehicle.year!,
                                        color: Colors.black54,
                                      ),
                                      
                                    // Color
                                    if (vehicle.color != null)
                                      VehicleUIHelpers.buildSpecChip(
                                        context: context,
                                        icon: Icons.palette_outlined,
                                        label: vehicle.color!,
                                        color: Colors.black54,
                                      ),
                                    
                                    // Fuel Type
                                    if (vehicle.fuelType != null)
                                      VehicleUIHelpers.buildSpecChip(
                                        context: context,
                                        icon: Icons.local_gas_station_outlined,
                                        label: vehicle.fuelType!,
                                        color: Colors.black54,
                                      ),
                                  ],
                                ),
                                
                                // Features section
                                if (vehicle.features != null && vehicle.features!.isNotEmpty) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 22),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Features heading
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.stars,
                                              size: 16,
                                              color: vehicleColor,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Features",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // Feature tags in a grid-like arrangement
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: vehicle.features!.take(4).map((feature) => 
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.03),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                feature,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black.withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          ).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Edit indicator hint
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: vehicleColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                color: vehicleColor,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Tap to edit",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: vehicleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
