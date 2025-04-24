import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/services/map_service.dart';

class MapBoxSearchService {
  static const String _baseUrl = 'https://api.mapbox.com/search/searchbox/v1';
  
  /// Fetches location suggestions based on the search query
  static Future<List<MapBoxPlace>> getSuggestions({
    required String query,
    required String sessionToken,
    String country = 'IN',
  }) async {
    final apiKey = MapService.mapBoxAccessToken;
    final endpoint = '$_baseUrl/suggest'
        '?q=$query'
        '&country=$country'
        '&access_token=$apiKey'
        '&session_token=$sessionToken';

    try {
      final response = await http.get(Uri.parse(endpoint));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>;
        
        return suggestions.map((suggestion) {
          final name = suggestion['name'] as String;
          final placeFormatted = suggestion['place_formatted'] as String;
          final mapboxId = suggestion['mapbox_id'] as String;
          
          return MapBoxPlace(
            placeName: '$name - $placeFormatted',
            mapboxId: mapboxId,
            longitude: 0,
            latitude: 0,
          );
        }).toList();
      } else {
        final error = json.decode(response.body);
        throw MapBoxSearchException(
          'Failed to fetch suggestions: ${error['message'] ?? 'Unknown error'}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MapBoxSearchException) rethrow;
      throw MapBoxSearchException('Network error: $e', 0);
    }
  }

  /// Retrieves detailed place information using the mapbox_id
  static Future<MapBoxPlace> retrievePlace({
    required String mapboxId,
    required String sessionToken,
  }) async {
    final apiKey = MapService.mapBoxAccessToken;
    final endpoint = '$_baseUrl/retrieve'
        '/$mapboxId'
        '?access_token=$apiKey'
        '&session_token=$sessionToken';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feature = data['features'][0];
        final properties = feature['properties'];
        final coordinates = feature['geometry']['coordinates'];
        
        return MapBoxPlace(
          placeName: '${properties['name']} - ${properties['place_formatted']}',
          longitude: coordinates[0],
          latitude: coordinates[1],
          mapboxId: properties['mapbox_id'],
        );
      } else {
        final error = json.decode(response.body);
        throw MapBoxSearchException(
          'Failed to retrieve place: ${error['message'] ?? 'Unknown error'}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MapBoxSearchException) rethrow;
      throw MapBoxSearchException('Network error: $e', 0);
    }
  }
}

/// Custom exception for MapBox Search API errors
class MapBoxSearchException implements Exception {
  final String message;
  final int statusCode;

  MapBoxSearchException(this.message, this.statusCode);

  @override
  String toString() => message;
} 