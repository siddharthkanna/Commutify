// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/components/map_widget.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;
  List<MapBoxPlace> _suggestions = [];
  List<MapBoxPlace> _recentSearches = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    // In a real app, you would load these from local storage
    // For now, we'll use dummy data
    setState(() {
      _recentSearches = [
        MapBoxPlace(
          placeName: 'Home - 123 Main Street, Bengaluru',
          longitude: 77.5946,
          latitude: 12.9716,
        ),
        MapBoxPlace(
          placeName: 'Work - Tech Park, Bengaluru',
          longitude: 77.6196,
          latitude: 12.9312,
        ),
        MapBoxPlace(
          placeName: 'MG Road, Bengaluru',
          longitude: 77.6101,
          latitude: 12.9749,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _searchController.text;
    setState(() {
      _showClearButton = query.isNotEmpty;
    });
    
    if (query.length > 2) {
      updateSuggestions(query);
    } else if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _clearText() {
    HapticFeedback.lightImpact();
    setState(() {
      _searchController.clear();
      _showClearButton = false;
      _suggestions = [];
    });
  }

  Future<List<MapBoxPlace>> fetchLocationSuggestions(String query) async {
    final apiKey = mapBoxAccessToken;
    const country = 'IN';
    final endpoint =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?country=$country&access_token=$apiKey';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List<dynamic>;
      return features
          .map((feature) => MapBoxPlace(
                placeName: feature['place_name'],
                longitude: feature['geometry']['coordinates'][0],
                latitude: feature['geometry']['coordinates'][1],
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch location suggestions');
    }
  }

  Future<void> updateSuggestions(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final results = await fetchLocationSuggestions(query);
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load suggestions. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _selectLocation(MapBoxPlace place) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, [place]);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      backgroundColor: Apptheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              margin: EdgeInsets.only(
                top: isPortrait ? 8 : 4,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: Apptheme.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Apptheme.primary.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Apptheme.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Apptheme.text,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for a location',
                        hintStyle: TextStyle(
                          color: Apptheme.textSecondary,
                          fontSize: 16.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        suffixIcon: _showClearButton
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearText,
                                color: Apptheme.textSecondary,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Apptheme.primary,
                ),
              ),
              
            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Apptheme.error,
                    fontSize: 14,
                  ),
                ),
              ),
              
            // Results section
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentSearches()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Apptheme.text,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final place = _recentSearches[index];
              return _buildPlaceItem(
                place: place,
                icon: Icons.history,
                iconColor: Apptheme.textSecondary,
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchResults() {
    if (_suggestions.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Apptheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: Apptheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildPlaceItem(
          place: suggestion,
          icon: Icons.location_on,
          iconColor: Apptheme.primary,
        );
      },
    );
  }
  
  Widget _buildPlaceItem({
    required MapBoxPlace place,
    required IconData icon,
    required Color iconColor,
  }) {
    final hasSecondaryText = place.placeName.contains(' - ');
    String primaryText = place.placeName;
    String secondaryText = '';
    
    if (hasSecondaryText) {
      final parts = place.placeName.split(' - ');
      primaryText = parts.first;
      secondaryText = parts.last;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Apptheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectLocation(place),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Apptheme.text,
                        ),
                      ),
                      if (hasSecondaryText) ...[
                        const SizedBox(height: 4),
                        Text(
                          secondaryText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Apptheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
