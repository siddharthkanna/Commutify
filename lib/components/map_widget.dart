//ignore: constant_identifier_names
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:commutify/Themes/app_theme.dart';


// Using direct values instead of env variables for debugging
final mapBoxAccessToken = dotenv.env['accessToken'];
final mapBoxStyleId = dotenv.env['styleId']?.replaceAll('mapbox://', '') ?? 'cli6i055s00pt01qua5srcxrl';
const myLocation = LatLng(0, 0);

// Print debug information
void printMapBoxDebugInfo() {
  // Only log if token is invalid
  if (mapBoxAccessToken?.isEmpty == true) {
    debugPrint('Warning: MapBox access token is empty');
  }
  testMapboxToken();
}

Future<void> testMapboxToken() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.mapbox.com/geocoding/v5/mapbox.places/New York.json?access_token=$mapBoxAccessToken')
    );
    if (response.statusCode != 200) {
      debugPrint('MapBox token validation failed: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error testing MapBox token: $e');
  }
}

Future<String> getAddressFromCoordinates(
    double latitude, double longitude) async {
  final apiKey = mapBoxAccessToken;
  final url =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].length > 0) {
        return data['features'][0]['place_name'];
      } else {
        return 'Unknown Location';
      }
    } else {
      return 'Error fetching address';
    }
  } catch (e) {
    return 'Error fetching address';
  }
}

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
  // Default location - San Francisco
  final LatLng defaultLocation = LatLng(37.7749, -122.4194);

  _MapWidgetState() : mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Debug MapBox configuration
    printMapBoxDebugInfo();
    
    // Initialize with delayed to ensure we catch any map loading errors
    Future.delayed(Duration.zero, () {
      try {
        if (mapBoxAccessToken?.isEmpty == true) {
          setState(() {
            hasMapLoadError = true;
            mapErrorMessage = "MapBox access token is empty - trying OpenStreetMap as fallback";
          });
          debugPrint("Warning: MapBox access token is empty - using OpenStreetMap fallback");
        }
        
        // Move to location - use default if none provided
        LatLng center = widget.pickupLocation ?? defaultLocation;
        mapController.move(center, 13.0);
      } catch (e) {
        setState(() {
          hasMapLoadError = true;
          mapErrorMessage = "Error initializing map: $e";
        });
        debugPrint("Error initializing map: $e");
      }
    });
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if pickup location has changed
    if (widget.pickupLocation != oldWidget.pickupLocation) {
      moveToPickupLocation();
    }

    // Check if destination location has changed
    if (widget.destinationLocation != oldWidget.destinationLocation) {
      moveToDestinationLocation();
    }
    
    // Calculate route if either location changes or when both are available
    if ((widget.pickupLocation != oldWidget.pickupLocation || 
         widget.destinationLocation != oldWidget.destinationLocation) &&
         widget.pickupLocation != null && 
         widget.destinationLocation != null) {
      // Force fixed testing route when on development
      createTestRoute();
    }
  }

  void moveToPickupLocation() {
    if (widget.pickupLocation != null) {
      mapController.move(widget.pickupLocation!, 20.0);
    } else {
      mapController.move(myLocation, 30);
    }
  }

  void moveToDestinationLocation() {
    if (widget.destinationLocation != null) {
      mapController.move(widget.destinationLocation!, 20.0);
    }
  }

  Future<void> getRouteCoordinates() async {
    if (widget.pickupLocation != null && widget.destinationLocation != null) {
      setState(() {
        isRouteLoading = true;
        // Clear previous route to avoid showing stale data
        routeCoordinates = [];
      });
      
      try {
        final response = await http.get(
          Uri.parse(
            "https://api.mapbox.com/directions/v5/mapbox/driving/${widget.pickupLocation!.longitude},${widget.pickupLocation!.latitude};${widget.destinationLocation!.longitude},${widget.destinationLocation!.latitude}?geometries=geojson&overview=full&access_token=$mapBoxAccessToken",
          ),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final List<dynamic> coordinates =
                data['routes'][0]['geometry']['coordinates'];
                
            if (coordinates.isNotEmpty) {
              // Convert coordinates format
              final List<LatLng> newRouteCoordinates = coordinates
                  .map<LatLng>((coord) {
                    // Mapbox returns [longitude, latitude]
                    return LatLng(coord[1], coord[0]);
                  })
                  .toList();
              
              setState(() {
                routeCoordinates = newRouteCoordinates;
                
                // Log route data for debugging
                debugPrint("ROUTE DEBUG: Route found with ${routeCoordinates.length} points");
                
                // Adjust map to show the entire route
                adjustMapZoom();
                isRouteLoading = false;
              });
            } else {
              debugPrint("ROUTE DEBUG: No coordinates found in route response");
              setState(() {
                isRouteLoading = false;
              });
            }
          } else {
            debugPrint("ROUTE DEBUG: No routes found in response: ${response.body}");
            setState(() {
              isRouteLoading = false;
            });
          }
        } else {
          debugPrint("ROUTE DEBUG: Error calculating route: ${response.statusCode} - ${response.body}");
          setState(() {
            isRouteLoading = false;
          });
        }
      } catch (e) {
        debugPrint("ROUTE DEBUG: Exception calculating route: $e");
        setState(() {
          isRouteLoading = false;
        });
      }
    } else {
      debugPrint("ROUTE DEBUG: Cannot calculate route - pickup or destination is null");
    }
  }

  void adjustMapZoom() {
    if (routeCoordinates.isNotEmpty) {
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (final coord in routeCoordinates) {
        if (coord.latitude < minLat) minLat = coord.latitude;
        if (coord.latitude > maxLat) maxLat = coord.latitude;
        if (coord.longitude < minLng) minLng = coord.longitude;
        if (coord.longitude > maxLng) maxLng = coord.longitude;
      }

      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      try {
        // Add a slight delay to allow animations to settle
        Future.delayed(const Duration(milliseconds: 300), () {
          mapController.fitBounds(
            bounds,
            options: const FitBoundsOptions(
              padding: EdgeInsets.all(80.0),
              maxZoom: 16.0,
            ),
          );
          
          debugPrint("Map adjusted to show full route");
        });
      } catch (e) {
        debugPrint("Error adjusting map zoom: $e");
      }
    }
  }

  // Create a test route for debugging
  void createTestRoute() {
    if (widget.pickupLocation != null && widget.destinationLocation != null) {
      debugPrint("ROUTE TESTING: Creating direct test route");
      
      // Create a simple straight line route between pickup and destination
      final LatLng start = widget.pickupLocation!;
      final LatLng end = widget.destinationLocation!;
      
      // Generate a few points to form a route
      final List<LatLng> testRoute = [
        start,
        LatLng(
          start.latitude + (end.latitude - start.latitude) * 0.25,
          start.longitude + (end.longitude - start.longitude) * 0.25
        ),
        LatLng(
          start.latitude + (end.latitude - start.latitude) * 0.5,
          start.longitude + (end.longitude - start.longitude) * 0.5
        ),
        LatLng(
          start.latitude + (end.latitude - start.latitude) * 0.75,
          start.longitude + (end.longitude - start.longitude) * 0.75
        ),
        end
      ];
      
      debugPrint("ROUTE TESTING: Created test route with ${testRoute.length} points");
      debugPrint("ROUTE TESTING: Start: $start, End: $end");
      
      setState(() {
        routeCoordinates = testRoute;
        adjustMapZoom();
      });
      
      // Also try regular route calculation for comparison
      getRouteCoordinates();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use direct hardcoded values for debugging
    // Try Mapbox raster tiles instead of vector tiles
    const String urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}@2x.png?access_token={accessToken}";
    final Map<String, String> additionalOptions = {
      'accessToken': mapBoxAccessToken ?? '',
    };
    
    debugPrint("ROUTE DEBUG: Building map with ${routeCoordinates.length} route points");
    if (routeCoordinates.isNotEmpty) {
      debugPrint("ROUTE DEBUG: First route point: ${routeCoordinates.first}, Last route point: ${routeCoordinates.last}");
    }
    
    return Stack(
      children: [
        // Display error message if map fails to load
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
        
        // Regular map content
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
                    // Disable rotation
                  ),
                  children: [
                    // Try MapBox first
                    TileLayer(
                      urlTemplate: urlTemplate,
                      additionalOptions: additionalOptions,
                      // Add a fallback to OpenStreetMap if MapBox fails
                      fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // Credit to OpenStreetMap
                      tileProvider: NetworkTileProvider(),
                    ),
                    
                    // Route polyline - Using plain bright colors for maximum visibility
                    if (routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routeCoordinates,
                            strokeWidth: 10.0,
                            color: Colors.red,
                            borderStrokeWidth: 5.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                      
                    // Pickup location marker
                    if (widget.pickupLocation != null)
                      MarkerLayer(
                        markers: [
                          // Only show pickup marker
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: widget.pickupLocation!,
                            builder: (context) => _buildPickupMarker(),
                          ),
                          // Show destination marker if available
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
              } catch (e, stackTrace) {
                debugPrint("ERROR in FlutterMap: $e");
                debugPrint("Stack trace: $stackTrace");
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
        // Loading indicator for route - improved visibility
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
