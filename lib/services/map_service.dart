import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

/// Service class to handle all MapBox API related operations
class MapService {
  static final String? _mapBoxAccessToken = dotenv.env['accessToken'];
  static final String _mapBoxStyleId = dotenv.env['styleId']?.replaceAll('mapbox://', '') ?? 'cli6i055s00pt01qua5srcxrl';

  // Base URLs for MapBox APIs
  static const String _baseGeocodingUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  static const String _baseDirectionsUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving';

  // Getters for public access
  static String get mapBoxAccessToken {
    final token = _mapBoxAccessToken ?? '';
    if (token.isEmpty) {
      debugPrint("WARNING: MapBox access token is empty! Check your .env file");
    }
    return token;
  }
  static String get mapBoxStyleId => _mapBoxStyleId;

  /// Get address details from coordinates using MapBox Geocoding API
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    final url = Uri.parse('$_baseGeocodingUrl/$longitude,$latitude.json?access_token=$_mapBoxAccessToken');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final features = data['features'] as List<dynamic>?;
        
        if (features?.isNotEmpty ?? false) {
          return features![0]['place_name'] as String;
        }
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  /// Get route coordinates between two points using MapBox Directions API
  static Future<List<LatLng>?> getRouteCoordinates(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_baseDirectionsUrl/${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}?alternatives=true&'
      'geometries=geojson&language=en&overview=full&steps=true&'
      'access_token=$_mapBoxAccessToken'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final routes = data['routes'] as List<dynamic>?;
        
        if (routes != null && routes.isNotEmpty) {
          final coordinates = routes[0]['geometry']['coordinates'] as List<dynamic>;
          final List<LatLng> points = coordinates.map((coord) {
            final List<dynamic> point = coord as List<dynamic>;
            // Note: GeoJSON format is [longitude, latitude]
            return LatLng(point[1] as double, point[0] as double);
          }).toList();
          return points;
        }
      } else {
        debugPrint("MapBox API error: ${response.statusCode}");
      }
      return null;
    } catch (e) {
      debugPrint("Error getting route coordinates: $e");
      return null;
    }
  }

  /// Decode the polyline string into a list of coordinates
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        final b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (index < len && encoded.codeUnitAt(index - 1) >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        final b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (index < len && encoded.codeUnitAt(index - 1) >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  /// Calculate route details between two points
  /// 
  /// Returns a [RouteDetails] object containing:
  /// - distance (km)
  /// - duration (minutes)
  /// - route coordinates
  /// - status and message
  static Future<Map<String, dynamic>> getRouteDetails(
    MapBoxPlace? pickupLocation,
    MapBoxPlace? destinationLocation,
  ) async {
    if (pickupLocation == null || destinationLocation == null) {
      return _createRouteResponse(
        status: 'error',
        message: 'Missing locations'
      );
    }

    try {
      final url = Uri.parse(
        '$_baseDirectionsUrl/${pickupLocation.longitude},${pickupLocation.latitude};'
        '${destinationLocation.longitude},${destinationLocation.latitude}?'
        'geometries=geojson&overview=full&access_token=$mapBoxAccessToken'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final routes = data['routes'] as List<dynamic>?;
        
        if (routes?.isNotEmpty ?? false) {
          return _processRouteResponse(routes![0]);
        }
        
        return _createRouteResponse(
          status: 'error',
          message: 'No routes found'
        );
      }
      
      return _createRouteResponse(
        status: 'error',
        message: 'API error: ${response.statusCode}'
      );
    } catch (e) {
      return _createRouteResponse(
        status: 'error',
        message: 'Exception: $e'
      );
    }
  }

  /// Helper method to process route response
  static Map<String, dynamic> _processRouteResponse(Map<String, dynamic> route) {
    // Convert distance from meters to kilometers
    final distanceInKm = (route['distance'] as num) / 1000;
    
    // Convert duration from seconds to minutes
    final durationInMinutes = (route['duration'] as num) / 60;
    
    // Extract and convert coordinates
    final List<dynamic> coordinates = route['geometry']['coordinates'];
    final List<LatLng> routePoints = coordinates.map((coord) {
      final List<dynamic> point = coord as List<dynamic>;
      return LatLng(point[1] as double, point[0] as double);
    }).toList();
    
    final List<Map<String, double>> routeCoordinates = coordinates.map((coord) {
      final List<dynamic> point = coord as List<dynamic>;
      return {
        'longitude': point[0] as double,
        'latitude': point[1] as double
      };
    }).toList();

    return _createRouteResponse(
      status: 'success',
      message: 'Route calculated successfully',
      distance: double.parse(distanceInKm.toStringAsFixed(2)),
      duration: double.parse(durationInMinutes.toStringAsFixed(1)),
      route: routeCoordinates,
      routePoints: routePoints
    );
  }

  /// Helper method to create consistent route response format
  static Map<String, dynamic> _createRouteResponse({
    required String status,
    required String message,
    double distance = 0.0,
    double duration = 0.0,
    List<Map<String, double>>? route,
    List<LatLng>? routePoints,
  }) {
    return {
      'distance': distance,
      'duration': duration,
      'route': route ?? [],
      'routePoints': routePoints ?? [],
      'status': status,
      'message': message,
    };
  }
} 