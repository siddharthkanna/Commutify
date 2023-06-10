class MapBoxPlace {
  final String placeName;
  final double longitude;
  final double latitude;

  MapBoxPlace({
    required this.placeName,
    required this.longitude,
    required this.latitude,
  });

  factory MapBoxPlace.fromJson(Map<String, dynamic> json) {
    return MapBoxPlace(
      placeName: json['place_name'] as String,
      longitude: (json['center'][0] as num).toDouble(),
      latitude: (json['center'][1] as num).toDouble(),
    );
  }
}
