import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:commutify/models/map_box_place.dart';

class MapService {
  // Default Mapbox token in case .env fails
  static const String FALLBACK_MAPBOX_TOKEN = 'pk.eyJ1Ijoic2lkZGhhcnRoa2FubmEiLCJhIjoiY201aWN3amljMHJqdTJsc2czMmowN2NwOCJ9.9G2HoNPdQYrW1NuXX5CWDA';
  
  // Get the token from environment variables or use fallback
  static final String mapBoxAccessToken = dotenv.env['accessToken'] ?? FALLBACK_MAPBOX_TOKEN;

  /// Calculates the route details (distance, duration) between two points
  /// 
  /// Takes pickup and destination locations and returns a map with:
  /// - distance: in kilometers
  /// - duration: in minutes
  /// - route: list of coordinate points (if needed to draw route)
  static Future<Map<String, dynamic>> getRouteDetails(
    MapBoxPlace? pickupLocation,
    MapBoxPlace? destinationLocation,
  ) async {
    // Default return values
    Map<String, dynamic> result = {
      'distance': 0.0,
      'duration': 0.0,
      'route': [],
    };

    // Check if both locations are available
    if (pickupLocation == null || destinationLocation == null) {
      print('Cannot calculate route: One or both locations are missing');
      return result;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.mapbox.com/directions/v5/mapbox/driving/" +
          "${pickupLocation.longitude},${pickupLocation.latitude};" +
          "${destinationLocation.longitude},${destinationLocation.latitude}" +
          "?geometries=geojson&overview=full&access_token=$mapBoxAccessToken",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if routes exist
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          // Extract distance (convert from meters to kilometers)
          final distanceInMeters = route['distance'] as num;
          final distanceInKm = distanceInMeters / 1000;
          
          // Extract duration (convert from seconds to minutes)
          final durationInSeconds = route['duration'] as num;
          final durationInMinutes = durationInSeconds / 60;
          
          // Extract route coordinates
          final List<dynamic> coordinates = route['geometry']['coordinates'];
          final routePoints = coordinates.map((coord) => {
            'longitude': coord[0],
            'latitude': coord[1]
          }).toList();
          
          result = {
            'distance': double.parse(distanceInKm.toStringAsFixed(2)),
            'duration': double.parse(durationInMinutes.toStringAsFixed(1)),
            'route': routePoints,
          };
          
          print('Route calculated: ${distanceInKm.toStringAsFixed(2)} km, ${durationInMinutes.toStringAsFixed(1)} minutes');
        } else {
          print('No routes found in Mapbox response');
        }
      } else {
        print('Mapbox API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error calculating route: $e');
    }

    return result;
  }
} 