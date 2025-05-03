
import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:flutter/services.dart';
import 'package:commutify/services/recent_searches_service.dart';
import 'dart:math';
import 'dart:async';
import 'package:commutify/services/map_box_search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  
  String _sessionToken = '';
  bool _showClearButton = false;
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<MapBoxPlace> _suggestions = [];
  List<MapBoxPlace> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    _generateSessionToken();
    _loadRecentSearches();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _generateSessionToken() {
    _sessionToken = '${DateTime.now().millisecondsSinceEpoch}-${1000000 + Random().nextInt(9000000)}';
  }

  Future<void> _loadRecentSearches() async {
    final searches = await RecentSearchesService.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  void _onTextChanged() {
    final query = _searchController.text;
    setState(() {
      _showClearButton = query.isNotEmpty;
      _errorMessage = '';
    });
    
    _debounceTimer?.cancel();
    
    if (query.length > 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _updateSuggestions(query);
      });
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
      _errorMessage = '';
    });
  }

  Future<void> _updateSuggestions(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final results = await MapBoxSearchService.getSuggestions(
        query: query,
        sessionToken: _sessionToken,
      );
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectLocation(MapBoxPlace place) async {
    HapticFeedback.selectionClick();
    
    if (place.mapboxId != null) {
      try {
        final fullPlace = await MapBoxSearchService.retrievePlace(
          mapboxId: place.mapboxId!,
          sessionToken: _sessionToken,
        );
        await RecentSearchesService.addRecentSearch(fullPlace);
        if (mounted) {
          Navigator.pop(context, [fullPlace]);
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } else {
      await RecentSearchesService.addRecentSearch(place);
      if (mounted) {
        Navigator.pop(context, [place]);
      }
    }
  }

  Future<void> _clearRecentSearches() async {
    HapticFeedback.lightImpact();
    await RecentSearchesService.clearRecentSearches();
    setState(() {
      _recentSearches = [];
    });
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
            _buildSearchBar(isPortrait),
            if (_isLoading) _buildLoadingIndicator(),
            if (_errorMessage.isNotEmpty) _buildErrorMessage(),
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

  Widget _buildSearchBar(bool isPortrait) {
    return Container(
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
            icon: Icon(Icons.arrow_back, color: Apptheme.primary),
            onPressed: () => Navigator.pop(context),
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
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: Apptheme.primary,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        _errorMessage,
        style: TextStyle(
          color: Apptheme.error,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'No recent searches',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: Apptheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Apptheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'No results found',
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

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Apptheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Apptheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
