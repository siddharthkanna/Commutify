// ignore_for_file: prefer_const_constructors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/controllers/vehicle_controller.dart';
import 'package:commutify/utils/vehicle_ui_helpers.dart';
import 'package:commutify/utils/notification_utils.dart';
import 'package:commutify/services/vehicle_api.dart';
import '../../models/vehicle_modal.dart';
import 'package:flutter/material.dart';
import 'package:commutify/common/loading.dart';

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

    try {
      final fetchedVehicles = await VehicleApi.fetchVehicles();

      setState(() {
        vehicles = fetchedVehicles;
        isLoading = false;
      });
      
      if (mounted) {
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        NotificationUtils.showError(context, "Failed to fetch vehicles: $e");
      }
    }
  }

  Future<void> addVehicle() async {
    await VehicleController.addVehicle(
      context,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) => fetchVehicleData(),
      onError: (_) {}, // Notification is already handled in the controller
    );
  }

  Future<void> editVehicle(Vehicle vehicle) async {
    await VehicleController.editVehicle(
      context,
      vehicle,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) => fetchVehicleData(),
      onError: (_) {}, // Notification is already handled in the controller
    );
  }

  Future<void> deleteVehicle(String vehicleId, String vehicleName) async {
    await VehicleController.deleteVehicle(
      context,
      vehicleId,
      vehicleName,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
      onSuccess: (message) => fetchVehicleData(),
      onError: (_) {}, // Notification is already handled in the controller
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
    return const Center(
      child: Loader(),
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
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: vehicleColor.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => editVehicle(vehicle),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        decoration: BoxDecoration(
                          color: vehicleColor.withOpacity(0.03),
                          border: Border(
                            bottom: BorderSide(
                              color: vehicleColor.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                // Vehicle icon
                                Container(
                                  width: screenSize.width * 0.13,
                                  height: screenSize.width * 0.13,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: vehicleColor.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    VehicleUIHelpers.getVehicleIcon(vehicle.vehicleType),
                                    color: vehicleColor,
                                    size: screenSize.width * 0.065,
                                  ),
                                ),
                                SizedBox(width: screenSize.width * 0.035),
                                
                                // Vehicle info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.vehicleName,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.042,
                                          fontWeight: FontWeight.w600,
                                          color: Apptheme.noir,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: screenSize.width * 0.012),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width * 0.02,
                                          vertical: screenSize.width * 0.008,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          vehicle.vehicleNumber,
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.034,
                                            color: Apptheme.noir.withOpacity(0.7),
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Three-dot menu
                            Positioned(
                              top: 0,
                              right: 0,
                              child: PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Apptheme.noir.withOpacity(0.6),
                                  size: screenSize.width * 0.05,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                elevation: 4,
                                position: PopupMenuPosition.under,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    height: 44,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Apptheme.noir.withOpacity(0.8),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Apptheme.noir,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    height: 44,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    editVehicle(vehicle);
                                  } else if (value == 'delete') {
                                    deleteVehicle(vehicle.id!, vehicle.vehicleName);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Details section
                      Container(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicle specs
                            Wrap(
                              spacing: screenSize.width * 0.02,
                              runSpacing: screenSize.width * 0.02,
                              children: [
                                _buildSpecChip(
                                  icon: Icons.directions_car_filled_outlined,
                                  label: vehicle.vehicleType,
                                  color: vehicleColor,
                                  isPrimary: true,
                                ),
                                if (vehicle.capacity > 0)
                                  _buildSpecChip(
                                    icon: Icons.people_alt_outlined,
                                    label: "${vehicle.capacity} seats",
                                    color: Colors.grey.shade700,
                                  ),
                                if (vehicle.make != null || vehicle.model != null)
                                  _buildSpecChip(
                                    icon: Icons.info_outline,
                                    label: [vehicle.make, vehicle.model]
                                        .where((e) => e != null && e.isNotEmpty)
                                        .join(' '),
                                    color: Colors.grey.shade700,
                                  ),
                                if (vehicle.year != null)
                                  _buildSpecChip(
                                    icon: Icons.calendar_today_outlined,
                                    label: vehicle.year!,
                                    color: Colors.grey.shade700,
                                  ),
                              ],
                            ),
                            
                            // Features section if available
                            if (vehicle.features != null && vehicle.features!.isNotEmpty) ...[
                              SizedBox(height: screenSize.width * 0.045),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(screenSize.width * 0.035),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: screenSize.width * 0.045,
                                          color: vehicleColor,
                                        ),
                                        SizedBox(width: screenSize.width * 0.015),
                                        Text(
                                          "Features",
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.036,
                                            fontWeight: FontWeight.w600,
                                            color: Apptheme.noir,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenSize.width * 0.025),
                                    Wrap(
                                      spacing: screenSize.width * 0.02,
                                      runSpacing: screenSize.width * 0.02,
                                      children: vehicle.features!.take(4).map((feature) =>
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenSize.width * 0.025,
                                            vertical: screenSize.width * 0.012,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              fontSize: screenSize.width * 0.032,
                                              color: Apptheme.noir.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSpecChip({
    required IconData icon,
    required String label,
    required Color color,
    bool isPrimary = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isPrimary ? color.withOpacity(0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? color.withOpacity(0.2) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isPrimary ? color : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isPrimary ? color : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
