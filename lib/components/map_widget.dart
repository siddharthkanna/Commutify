// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/services/map_service.dart';
import 'package:commutify/common/error.dart';
import 'dart:math' as math;

class MapWidget extends StatefulWidget {
  final LatLng? pickupLocation;
  final LatLng? destinationLocation;
  final bool isCurrentLocation;

  const MapWidget({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
    this.isCurrentLocation = false,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late MapController mapController;
  List<LatLng> routeCoordinates = [];
  bool isRouteLoading = false;
  bool hasMapLoadError = false;
  String? mapErrorMessage;
  final LatLng defaultLocation = LatLng(37.7749, -122.4194);

  _MapWidgetState() : mapController = MapController();

  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration.zero, () {
      try {
        if (MapService.mapBoxAccessToken.isEmpty) {
          setState(() {
            hasMapLoadError = true;
            mapErrorMessage = "MapBox access token is empty - trying OpenStreetMap as fallback";
          });
        }
        
        LatLng center = widget.pickupLocation ?? defaultLocation;
        mapController.move(center, 13.0);

        if (widget.pickupLocation != null && widget.destinationLocation != null) {
          getRouteCoordinates();
        }
      } catch (e) {
        setState(() {
          hasMapLoadError = true;
          mapErrorMessage = "Error initializing map: $e";
        });
      }
    });
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pickupLocation != oldWidget.pickupLocation) {
      moveToPickupLocation();
    }

    if (widget.destinationLocation != oldWidget.destinationLocation) {
      moveToDestinationLocation();
    }
    
    if ((widget.pickupLocation != oldWidget.pickupLocation || 
         widget.destinationLocation != oldWidget.destinationLocation) &&
         widget.pickupLocation != null && 
         widget.destinationLocation != null) {
      getRouteCoordinates();
    }
  }

  void moveToPickupLocation() {
    if (widget.pickupLocation != null) {
      mapController.move(widget.pickupLocation!, 15.0);
    }
  }

  void moveToDestinationLocation() {
    if (widget.destinationLocation != null) {
      mapController.move(widget.destinationLocation!, 15.0);
      
      if (widget.pickupLocation != null) {
        getRouteCoordinates();
      }
    }
  }

  Future<void> getRouteCoordinates() async {
    if (widget.pickupLocation != null && widget.destinationLocation != null) {
      setState(() {
        isRouteLoading = true;
        routeCoordinates = [];
      });
      
      try {
        final newRouteCoordinates = await MapService.getRouteCoordinates(
          widget.pickupLocation!,
          widget.destinationLocation!
        );
        
        if (newRouteCoordinates != null && newRouteCoordinates.isNotEmpty) {
          setState(() {
            routeCoordinates = newRouteCoordinates;
            adjustMapZoom();
          });
        } else {
          // If no route is found, it means the locations are not routable
          if (mounted && context.mounted) {
            Snackbar.showWarningSnackbar(
              context,
              "Unable to find a valid route between these locations. The destinations might be across water bodies or in unreachable areas."
            );
          }
        }
      } catch (e) {
        if (mounted && context.mounted) {
          Snackbar.showErrorSnackbar(context, "Error calculating route: $e");
        }
      } finally {
        setState(() {
          isRouteLoading = false;
        });
      }
    }
  }

  void adjustMapZoom() {
    if (routeCoordinates.isNotEmpty) {
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      if (widget.pickupLocation != null) {
        minLat = math.min(minLat, widget.pickupLocation!.latitude);
        maxLat = math.max(maxLat, widget.pickupLocation!.latitude);
        minLng = math.min(minLng, widget.pickupLocation!.longitude);
        maxLng = math.max(maxLng, widget.pickupLocation!.longitude);
      }
      
      if (widget.destinationLocation != null) {
        minLat = math.min(minLat, widget.destinationLocation!.latitude);
        maxLat = math.max(maxLat, widget.destinationLocation!.latitude);
        minLng = math.min(minLng, widget.destinationLocation!.longitude);
        maxLng = math.max(maxLng, widget.destinationLocation!.longitude);
      }

      for (final coord in routeCoordinates) {
        minLat = math.min(minLat, coord.latitude);
        maxLat = math.max(maxLat, coord.latitude);
        minLng = math.min(minLng, coord.longitude);
        maxLng = math.max(maxLng, coord.longitude);
      }

      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      try {
        mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(
            padding: EdgeInsets.all(120.0),
            maxZoom: 15.0,
          ),
        );
      } catch (e) {
        debugPrint("Error adjusting map zoom: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}@2x.png?access_token={accessToken}";
    final Map<String, String> additionalOptions = {
      'accessToken': MapService.mapBoxAccessToken,
    };
    
    return Stack(
      children: [
        if (hasMapLoadError)
          Container(
            color: Apptheme.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 60, color: Apptheme.error),
                  SizedBox(height: 20),
                  Text(
                    'Unable to load map',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Apptheme.text,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (mapErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        mapErrorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Apptheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        
        if (!hasMapLoadError)
          Builder(
            builder: (context) {
              try {
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    minZoom: 5,
                    maxZoom: 18,
                    zoom: 13,
                    center: widget.pickupLocation ?? defaultLocation,
                    interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: urlTemplate,
                      additionalOptions: additionalOptions,
                      fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: NetworkTileProvider(),
                    ),
                    
                    if (routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routeCoordinates,
                            strokeWidth: 4.0,
                            color: Colors.blue.shade600,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white.withOpacity(0.9),
                            isDotted: false,
                            gradientColors: [
                              Colors.blue.shade500,
                              Colors.blue.shade600,
                              Colors.blue.shade700,
                            ],
                          ),
                        ],
                      ),
                      
                    if (widget.pickupLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: widget.pickupLocation!,
                            builder: (context) => _buildPickupMarker(),
                          ),
                          if (widget.destinationLocation != null)
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: widget.destinationLocation!,
                              builder: (context) => _buildDestinationMarker(),
                            ),
                        ],
                      ),
                  ],
                );
              } catch (e) {
                return Container(
                  color: Apptheme.background,
                  child: Center(
                    child: Text(
                      'Error loading map: $e',
                      style: TextStyle(color: Apptheme.error),
                    ),
                  ),
                );
              }
            },
          ),

        if (isRouteLoading)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Apptheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Apptheme.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Calculating route...',
                      style: TextStyle(
                        color: Apptheme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPickupMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Apptheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Apptheme.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.circle,
              color: Apptheme.surface,
              size: 10,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 10,
          color: Apptheme.success,
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Apptheme.success,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDestinationMarker() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Apptheme.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Apptheme.surface,
              size: 14,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Apptheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
