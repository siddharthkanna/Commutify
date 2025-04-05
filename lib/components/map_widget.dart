import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final mapBoxAccessToken = dotenv.env['accessToken']!;
final mapBoxStyleId = dotenv.env['styleId']!;
const myLocation = LatLng(0, 0);

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

  _MapWidgetState() : mapController = MapController();

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if pickup location has changed
    if (widget.pickupLocation != oldWidget.pickupLocation) {
      moveToPickupLocation();
      getRouteCoordinates();
    }

    // Check if destination location has changed
    if (widget.destinationLocation != oldWidget.destinationLocation) {
      moveToDestinationLocation();
      getRouteCoordinates();
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
      });
      
      try {
        final response = await http.get(
          Uri.parse(
            "https://api.mapbox.com/directions/v5/mapbox/driving/${widget.pickupLocation!.longitude},${widget.pickupLocation!.latitude};${widget.destinationLocation!.longitude},${widget.destinationLocation!.latitude}?geometries=geojson&access_token=$mapBoxAccessToken",
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> coordinates =
              data['routes'][0]['geometry']['coordinates'];
          setState(() {
            routeCoordinates =
                coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
            adjustMapZoom();
            isRouteLoading = false;
          });
        } else {
          setState(() {
            isRouteLoading = false;
          });
        }
      } catch (e) {
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

      mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(110.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            minZoom: 5,
            maxZoom: 18,
            zoom: 13,
            center: widget.pickupLocation ?? myLocation,
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            // Disable rotation
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/siddharthkanna/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
              additionalOptions: {
                'mapStyleId': mapBoxStyleId,
                'accessToken': mapBoxAccessToken,
              },
            ),
            // Route polyline
            if (routeCoordinates.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeCoordinates,
                    strokeWidth: 4.0,
                    color: Colors.blue.shade800.withOpacity(0.7),
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.white.withOpacity(0.7),
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
        ),
        // Loading indicator for route
        if (isRouteLoading)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Calculating route...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
            color: Colors.white,
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
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.circle,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 10,
          color: Colors.green,
        ),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.green,
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
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -5),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
