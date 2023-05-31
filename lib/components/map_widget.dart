import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

final mapBoxAccessToken = dotenv.env['accessToken']!;
final mapBoxStyleId = dotenv.env['styleId']!;
final myLocation = LatLng(17.3850, 78.4867);

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
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
  }

  void moveToPickupLocation() {
    if (widget.pickupLocation != null) {
      mapController.move(widget.pickupLocation!, 20.0);
    }else{
      mapController.move(myLocation, 30);
    }
  }

  void moveToDestinationLocation() {
    if (widget.destinationLocation != null) {
      mapController.move(widget.destinationLocation!, 20.0);
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
        MarkerLayer(
          markers: [
            Marker(
              width: 200.0,
              height: 200.0,
              point: widget.pickupLocation!,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
            ),
            Marker(
              width: 200.0,
              height: 200.0,
              point: widget.destinationLocation!,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.red,
              ),
            ),
            if(widget.isCurrentLocation)
            Marker(
              width: 200.0,
              height: 200.0,
              point: widget.pickupLocation!,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.green,
              ),
            ),
            

          ],
        ),
      ],
    );
  }
}
