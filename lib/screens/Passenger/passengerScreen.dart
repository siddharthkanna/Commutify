// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/services/ride_api.dart';
import '../../models/ride_modal.dart';
import '../../models/map_box_place.dart';
import './book_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class PassengerScreen extends ConsumerStatefulWidget {
  final MapBoxPlace? pickupLocation;
  final MapBoxPlace? destinationLocation;
  final int? requiredSeats;
  final DateTime? selectedDate;
  final double? maxPrice;

  const PassengerScreen({
    super.key, 
    required this.pickupLocation,
    required this.destinationLocation,
    this.requiredSeats = 1,
    this.selectedDate,
    this.maxPrice,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PassengerScreenState createState() => _PassengerScreenState();
}

class _PassengerScreenState extends ConsumerState<PassengerScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Ride> rides = [];
  List<String> filters = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool isRefreshing = false;
  
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    fetchRidesFromBackend();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchRidesFromBackend() async {
    if (isRefreshing) return;
    
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final List<Ride> fetchedRides = await RideApi.fetchAvailableRides(
        // Text-based location names
        pickupLocation: widget.pickupLocation?.placeName,
        destinationLocation: widget.destinationLocation?.placeName,
        
        // Coordinates for more precise search
        pickupLat: widget.pickupLocation?.latitude,
        pickupLng: widget.pickupLocation?.longitude,
        destinationLat: widget.destinationLocation?.latitude,
        destinationLng: widget.destinationLocation?.longitude,
        
        // Filters
        maxPrice: widget.maxPrice,
        date: widget.selectedDate,
        requiredSeats: widget.requiredSeats,
      );
      
      setState(() {
        rides = fetchedRides;
        isLoading = false;
        
        // Trigger animation
        if (hasActiveFilters()) {
          _animationController.forward();
        }
      });
    } catch (error) {
      debugPrint('Error fetching rides: $error');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load rides. Please try again.';
      });
    }
  }
  
  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    
    try {
      final List<Ride> fetchedRides = await RideApi.fetchAvailableRides(
        // Text-based location names
        pickupLocation: widget.pickupLocation?.placeName,
        destinationLocation: widget.destinationLocation?.placeName,
        
        // Coordinates for more precise search
        pickupLat: widget.pickupLocation?.latitude,
        pickupLng: widget.pickupLocation?.longitude,
        destinationLat: widget.destinationLocation?.latitude,
        destinationLng: widget.destinationLocation?.longitude,
        
        // Filters
        maxPrice: widget.maxPrice,
        date: widget.selectedDate,
        requiredSeats: widget.requiredSeats,
      );
      
      if (mounted) {
        setState(() {
          rides = fetchedRides;
          isRefreshing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${error.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  bool hasActiveFilters() {
    return widget.maxPrice != null || widget.selectedDate != null || widget.requiredSeats != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Rides',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Apptheme.noir,
              ),
            ),
            Text(
              'Find and book rides nearby',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Apptheme.noir),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Apptheme.primary,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Filter chips section
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildFilterSection(),
                ),
              ),
            ),
            
            // Rides list, loading, or error
            isLoading
                ? const SliverFillRemaining(
                    child: Center(child: Loader()),
                  )
                : hasError
                    ? SliverFillRemaining(
                        child: _buildErrorView(),
                      )
                    : rides.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyView(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.only(bottom: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return FadeTransition(
                                    opacity: _opacityAnimation,
                                    child: RideCard(ride: rides[index]),
                                  );
                                },
                                childCount: rides.length,
                              ),
                            ),
                          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Filter/Sort functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Advanced filtering coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Apptheme.primary,
        elevation: 2,
        child: const Icon(Icons.filter_list_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
                Icons.directions_car_outlined,
            size: 80,
                color: Colors.grey.shade400,
              ),
          const SizedBox(height: 16),
          Text(
              'No rides available',
              style: TextStyle(
              fontSize: 18,
                fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
              ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'There are no rides available at the moment. Pull to refresh or try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            ),
            const SizedBox(height: 24),
          ElevatedButton(
              onPressed: fetchRidesFromBackend,
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Refresh'),
            ),
          ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
                color: Colors.red.shade300,
              ),
          const SizedBox(height: 16),
            const Text(
            'Oops! Something went wrong',
              style: TextStyle(
              fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Apptheme.noir,
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            ),
            const SizedBox(height: 24),
          ElevatedButton(
              onPressed: fetchRidesFromBackend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Apptheme.primary,
                foregroundColor: Colors.white,
              elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Quick Filters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterBadge('All', isSelected: filters.isEmpty),
                _buildFilterBadge('Nearby', icon: Icons.near_me),
                _buildFilterBadge('Today', icon: Icons.today),
                _buildFilterBadge('Low price', icon: Icons.trending_down),
                _buildFilterBadge('4+ seats', icon: Icons.event_seat),
                _buildFilterBadge('Highly rated', icon: Icons.star),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, {IconData? icon, bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'All') {
            filters.clear();
          } else if (filters.contains(label)) {
            filters.remove(label);
          } else {
            filters.add(label);
          }
        });
        // Implement actual filtering logic here
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected || filters.contains(label)
              ? Apptheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected || filters.contains(label)
                ? Apptheme.primary
                : Colors.grey.shade300,
          ),
          boxShadow: isSelected || filters.contains(label)
              ? [
                  BoxShadow(
                    color: Apptheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected || filters.contains(label)
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected || filters.contains(label)
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

