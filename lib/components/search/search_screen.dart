import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/components/map_widget.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      backgroundColor: Apptheme.ivory,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isPortrait
                  ? screenSize.height * 0.06
                  : screenSize.width * 0.03,
              left: isPortrait
                  ? screenSize.width * 0.02
                  : screenSize.width * 0.04,
              right: isPortrait
                  ? screenSize.width * 0.02
                  : screenSize.width * 0.04,
            ),
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
              padding: EdgeInsets.symmetric(
                horizontal: isPortrait
                    ? screenSize.width * 0.02
                    : screenSize.width * 0.04,
              ),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(
                thickness: 1.5,
              ), // Add a Divider between items
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion.placeName,
                    style: TextStyle(
                        fontSize: isPortrait
                            ? screenSize.width * 0.04
                            : screenSize.width * 0.025,
                        fontWeight: FontWeight.normal),
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
