// lib/screens/homestay_list_screen.dart

import 'package:assignment2_app/services/api_services.dart';
import 'package:flutter/material.dart';
import '../models/homestay.dart';
import '../widgets/homestay_card.dart';

class HomestayListScreen extends StatefulWidget {
  const HomestayListScreen({super.key});

  @override
  State<HomestayListScreen> createState() => _HomestayListScreenState();
}

class _HomestayListScreenState extends State<HomestayListScreen> {
  // ─── State variables ──────────────────────────────────────────────────────
  List<Homestay> _homestays = [];
  List<String> _states = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Search / filter
  final TextEditingController _searchController = TextEditingController();
  String _selectedState = '';
  String _searchKeyword = '';

  // Search history (extra feature)
  final List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadHomestays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── API Calls ─────────────────────────────────────────────────────────────

  Future<void> _loadStates() async {
    try {
      final states = await ApiService.fetchStates();
      if (mounted) {
        setState(() => _states = ['All States', ...states]);
      }
    } catch (_) {
      // Non-critical – ignore silently
    }
  }

  Future<void> _loadHomestays({bool isRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (!isRefresh) _homestays = [];
    });

    try {
      final results = await ApiService.fetchHomestays(
        keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
        state: _selectedState.isEmpty || _selectedState == 'All States'
            ? null
            : _selectedState,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _homestays = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = _searchKeyword.isNotEmpty
                ? 'No homestay found for "$_searchKeyword".'
                : 'No homestay data available.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty && !_searchHistory.contains(keyword)) {
      setState(() => _searchHistory.insert(0, keyword));
    }
    setState(() => _searchKeyword = keyword);
    _loadHomestays();
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchKeyword = '');
    _loadHomestays();
  }

  void _onStateChanged(String? value) {
    if (value == null) return;
    setState(() => _selectedState = value);
    _loadHomestays();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'Homestay2U Malaysia',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
        // The hamburger icon is added automatically by Scaffold when a drawer is present
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () => _loadHomestays(isRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStateFilter(),
          if (_searchHistory.isNotEmpty && _searchController.text.isEmpty)
            _buildSearchHistory(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.teal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: 'Search homestay (e.g. river, beach, Sabah…)',
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => setState(() {}), // rebuild to show/hide clear icon
      ),
    );
  }

  // ─── State filter dropdown ─────────────────────────────────────────────────

  Widget _buildStateFilter() {
    if (_states.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Filter by State:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedState.isEmpty ? 'All States' : _selectedState,
              underline: const SizedBox(),
              items: _states
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: _onStateChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search history chips ──────────────────────────────────────────────────

  Widget _buildSearchHistory() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent searches:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: _searchHistory
                .take(5)
                .map(
                  (h) => ActionChip(
                    label: Text(h, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _searchController.text = h;
                      _onSearch();
                    },
                  ),
                )
                .toList(),
          ),
          const Divider(height: 8),
        ],
      ),
    );
  }

  // ─── Main body (loading / error / list) ────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Loading homestays…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _errorMessage!.toLowerCase().contains('internet') ||
                        _errorMessage!.toLowerCase().contains('network')
                    ? Icons.wifi_off
                    : Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _loadHomestays(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: () => _loadHomestays(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: _homestays.length + 1, // +1 for result count header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${_homestays.length} homestay(s) found',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            );
          }
          return HomestayCard(homestay: _homestays[index - 1]);
        },
      ),
    );
  }
}
