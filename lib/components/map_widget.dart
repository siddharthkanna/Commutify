import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final mapBoxAccessToken = dotenv.env['accessToken']!;
final mapBoxStyleId = dotenv.env['styleId']!;
const myLocation = LatLng(0, 0);

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
        options: const FitBoundsOptions(padding: EdgeInsets.all(110.0),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        minZoom: 5,
        maxZoom: 18,
        zoom: 13,
        center: widget.pickupLocation ?? myLocation,
        interactiveFlags: InteractiveFlag.pinchZoom |
            InteractiveFlag.drag,
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
        PolylineLayer(
          polylines: [
            Polyline(
              points: routeCoordinates,
              strokeWidth: 4.0,
              color: Colors.black54,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 250.0,
              height: 250.0,
              point: widget.pickupLocation!,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
            ),
            Marker(
              width: 200.0,
              height: 200.0,
              point: widget.destinationLocation ?? myLocation,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
