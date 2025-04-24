import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:latlong2/latlong.dart';

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
  /// - route: list of coordinate points to draw the route on map
  static Future<Map<String, dynamic>> getRouteDetails(
    MapBoxPlace? pickupLocation,
    MapBoxPlace? destinationLocation,
  ) async {
    // Default return values
    Map<String, dynamic> result = {
      'distance': 0.0,
      'duration': 0.0,
      'route': [],
      'routePoints': [],
      'status': 'error',
      'message': 'Missing locations',
    };

    // Check if both locations are available
    if (pickupLocation == null || destinationLocation == null) {
      return result;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.mapbox.com/directions/v5/mapbox/driving/${pickupLocation.longitude},${pickupLocation.latitude};${destinationLocation.longitude},${destinationLocation.latitude}?geometries=geojson&overview=full&access_token=$mapBoxAccessToken",
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
          
          // Convert to LatLng objects for direct use in Flutter Map
          final List<LatLng> routePoints = coordinates.map((coord) => 
            LatLng(coord[1], coord[0])
          ).toList();
          
          // Also keep the original format for other uses
          final routeCoordinates = coordinates.map((coord) => {
            'longitude': coord[0],
            'latitude': coord[1]
          }).toList();
          
          result = {
            'distance': double.parse(distanceInKm.toStringAsFixed(2)),
            'duration': double.parse(durationInMinutes.toStringAsFixed(1)),
            'route': routeCoordinates,
            'routePoints': routePoints,
            'status': 'success',
            'message': 'Route calculated successfully',
          };
        } else {
          result['status'] = 'error';
          result['message'] = 'No routes found';
        }
      } else {
        result['status'] = 'error';
        result['message'] = 'API error: ${response.statusCode}';
      }
    } catch (e) {
      result['status'] = 'error';
      result['message'] = 'Exception: $e';
    }

    return result;
  }
} 