import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/weather_provider.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    Future.microtask(
      () => Provider.of<WeatherProvider>(context, listen: false).loadWeather(),
    );
  }

  void _loadRecentSearches() {
    _recentSearches = ['Karachi', 'Lahore', 'Islamabad', 'Dubai'];
  }

  void _saveSearch(String city) {
    if (city.isNotEmpty && !_recentSearches.contains(city)) {
      setState(() {
        _recentSearches.insert(0, city);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      });
    }
  }

  void _performSearch(String city) {
    if (city.trim().isEmpty) return;

    _saveSearch(city);
    Provider.of<WeatherProvider>(context, listen: false).loadWeather(city);

    setState(() {
      _isSearching = false;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch(BuildContext context) {
    _searchController.clear();
    _isSearching = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchBottomSheet(
        searchController: _searchController,
        focusNode: _searchFocusNode,
        recentSearches: _recentSearches,
        onSearch: _performSearch,
        onClose: () => setState(() => _isSearching = false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF1F2B49), Color(0xFF060E20)],
          ),
        ),
        child: SafeArea(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? _errorUI(provider)
              : Column(
                  children: [
                    _topBar(provider),
                    const SizedBox(height: 20),
                    _temperatureSection(provider),
                    const SizedBox(height: 30),
                    _glassCard(provider),
                  ],
                ),
        ),
      ),
    );
  }

  // 🔝 TOP BAR
  Widget _topBar(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.near_me, color: Color(0xFFB6A0FF), size: 18),
                const SizedBox(width: 6),
                Text(
                  provider.city,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDEE5FF),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openSearch(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.search, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // 🌤 TEMPERATURE SECTION
  Widget _temperatureSection(WeatherProvider provider) {
    final temp = provider.weather?.temperature.toStringAsFixed(0) ?? "--";

    return Column(
      children: [
        const Text(
          "Live Weather",
          style: TextStyle(
            color: Colors.white54,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),

        Stack(
          alignment: Alignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white24],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                "$temp°",
                style: const TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              right: -20,
              top: 0,
              child: Icon(Icons.wb_sunny, size: 40, color: Colors.cyanAccent),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Clear Sky",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB6A0FF),
          ),
        ),
      ],
    );
  }

  // 🧊 GLASS CARD
  Widget _glassCard(WeatherProvider provider) {
    final temp = provider.weather?.temperature.toStringAsFixed(0) ?? "--";
    final wind = provider.weather?.windspeed.toStringAsFixed(0) ?? "--";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF192540).withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _item(Icons.thermostat, "Feels Like", "$temp°"),
                    _item(Icons.water_drop, "Humidity", "42%"),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _item(Icons.air, "Wind", "$wind km/h"),
                    _item(Icons.wb_sunny, "UV Index", "Low"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📦 ITEM
  Widget _item(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ❌ ERROR UI
  Widget _errorUI(WeatherProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            provider.error ?? "Something went wrong",
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              provider.loadWeather();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

// Professional Search Bottom Sheet
class _SearchBottomSheet extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final List<String> recentSearches;
  final Function(String) onSearch;
  final VoidCallback onClose;

  const _SearchBottomSheet({
    required this.searchController,
    required this.focusNode,
    required this.recentSearches,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _slideAnimation.value * MediaQuery.of(context).size.height,
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFF0A0F1C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  _buildHandle(),
                  _buildSearchField(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          controller: widget.searchController,
          focusNode: widget.focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFB6A0FF)),
            suffixIcon: widget.searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      widget.searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: (value) => widget.onSearch(value),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }
    return _buildRecentSearches();
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.recentSearches.clear();
                  });
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFFB6A0FF), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.recentSearches.length,
            itemBuilder: (context, index) {
              final city = widget.recentSearches[index];
              return _buildSearchTile(
                icon: Icons.history,
                title: city,
                subtitle: 'Tap to search',
                onTap: () => widget.onSearch(city),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final suggestions = _getSuggestions(widget.searchController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Suggestions',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final city = suggestions[index];
              return _buildSearchTile(
                icon: Icons.location_city,
                title: city,
                subtitle: 'Search for "$city"',
                onTap: () => widget.onSearch(city),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFB6A0FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFB6A0FF), size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  List<String> _getSuggestions(String query) {
    final cities = [
      'Karachi',
      'Lahore',
      'Islamabad',
      'Rawalpindi',
      'Faisalabad',
      'Multan',
      'Hyderabad',
      'Gujranwala',
      'Peshawar',
      'Quetta',
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'London',
      'New York',
      'Tokyo',
      'Paris',
      'Sydney',
      'Toronto',
      'Singapore',
    ];

    return cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}
