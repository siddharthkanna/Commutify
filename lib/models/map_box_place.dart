import 'package:latlong2/latlong.dart';

class MapBoxPlace {
  final String placeName;
  final double longitude;
  final double latitude;
  final String? mapboxId;

  MapBoxPlace({
    required this.placeName,
    required this.longitude,
    required this.latitude,
    this.mapboxId,
  });

  LatLng toLatLng(){
  return LatLng(latitude, longitude);
}

  

  factory MapBoxPlace.fromJson(Map<String, dynamic> json) {
    return MapBoxPlace(
      placeName: json['place_name'] as String,
      longitude: (json['center'][0] as num).toDouble(),
      latitude: (json['center'][1] as num).toDouble(),
      mapboxId: json['mapbox_id'] as String?,
    );
  }
}


