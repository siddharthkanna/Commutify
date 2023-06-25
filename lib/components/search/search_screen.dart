import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/components/map_widget.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
  }

  void _clearText() {
    setState(() {
      _searchController.clear();
      _showClearButton = false;
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
    final results = await fetchLocationSuggestions(query);
    setState(() {
      _suggestions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.conatainer,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (query) => updateSuggestions(query),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      hintText: _searchController.text.isEmpty
                          ? 'Search Location'
                          : '',
                      border: InputBorder.none,
                      suffixIcon: _showClearButton
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearText,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(
                thickness: 1.5,
              ), // Add a Divider between items
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion.placeName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                  onTap: () {
                    Navigator.pop(context, [suggestion]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
