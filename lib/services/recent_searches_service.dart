import 'dart:convert';
import 'package:commutify/models/map_box_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _key = 'recent_searches';
  static const int _maxRecentSearches = 5;

  /// Load recent searches from SharedPreferences
  static Future<List<MapBoxPlace>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? searchesJson = prefs.getString(_key);
      
      if (searchesJson == null) {
        return [];
      }

      final List<dynamic> searchesList = json.decode(searchesJson);
      return searchesList.map((item) => MapBoxPlace(
        placeName: item['placeName'],
        longitude: item['longitude'],
        latitude: item['latitude'],
      )).toList();
    } catch (e) {
      print('Error loading recent searches: $e');
      return [];
    }
  }

  /// Add a new search to recent searches
  static Future<void> addRecentSearch(MapBoxPlace place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<MapBoxPlace> searches = await getRecentSearches();
      
      // Remove if already exists to avoid duplicates
      searches.removeWhere((item) => 
        item.placeName == place.placeName && 
        item.latitude == place.latitude && 
        item.longitude == place.longitude
      );
      
      // Add new search at the beginning
      searches.insert(0, place);
      
      // Keep only the most recent searches
      if (searches.length > _maxRecentSearches) {
        searches = searches.sublist(0, _maxRecentSearches);
      }
      
      // Save to SharedPreferences
      final List<Map<String, dynamic>> searchesList = searches.map((item) => {
        'placeName': item.placeName,
        'longitude': item.longitude,
        'latitude': item.latitude,
      }).toList();
      
      await prefs.setString(_key, json.encode(searchesList));
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  /// Clear all recent searches
  static Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }
} 