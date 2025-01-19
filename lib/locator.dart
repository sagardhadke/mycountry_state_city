import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycountry_state_city/models/city.dart';
import 'package:mycountry_state_city/models/country.dart';
import 'package:mycountry_state_city/models/state.dart' as myState;
import 'package:mycountry_state_city/services/data_service.dart';

class locator extends StatefulWidget {
  const locator({super.key});

  @override
  State<locator> createState() => _locatorState();
}

class _locatorState extends State<locator> {
  final DataService _dataService = DataService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Cached data
  late Future<List<Country>> _countriesFuture;
  Map<String, List<myState.State>> _stateCache = {};
  Map<String, List<City>> _cityCache = {};

  Country? _selectedCountry;
  myState.State? _selectedState;
  City? _selectedCity;

  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countriesFuture = _dataService.loadCountries();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _openPickerSheet({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
    String? subtitle,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LocationPickerSheet(
        title: title,
        subtitle: subtitle,
        items: items,
        onSelected: onSelected,
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required String? Function(String?) validator,
    String? hint,
    bool enabled = true,
    IconData icon = Icons.location_on_outlined,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        elevation: enabled ? 4 : 1,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          onTap: enabled ? onTap : null,
          validator: validator,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: Icon(icon,
                color: enabled ? Theme.of(context).primaryColor : Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Location Selector'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where are you from?',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select your location details below',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                          const SizedBox(height: 32),
                          FutureBuilder<List<Country>>(
                            future: _countriesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              final countries = snapshot.data ?? [];

                              return Column(
                                children: [
                                  _buildLocationField(
                                    label: 'Country',
                                    hint: 'Select your country',
                                    controller: _countryController,
                                    icon: Icons.public,
                                    onTap: () => _openPickerSheet(
                                      title: 'Select Country',
                                      subtitle:
                                          'Choose your country from the list below',
                                      items:
                                          countries.map((c) => c.name).toList(),
                                      onSelected: (selected) async {
                                        final country = countries.firstWhere(
                                            (c) => c.name == selected);
                                        setState(() {
                                          _selectedCountry = country;
                                          _countryController.text =
                                              country.name;
                                          _selectedState = null;
                                          _selectedCity = null;
                                          _stateController.clear();
                                          _cityController.clear();
                                        });

                                        // Load states with caching
                                        if (!_stateCache
                                            .containsKey(country.isoCode)) {
                                          final states =
                                              await _dataService.loadStates();
                                          _stateCache[country.isoCode] = states
                                              .where((s) =>
                                                  s.countryCode ==
                                                  country.isoCode)
                                              .toList();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Please select a country'
                                        : null,
                                  ),
                                  _buildLocationField(
                                    label: 'State/Province',
                                    hint: 'Select your state',
                                    controller: _stateController,
                                    icon: Icons.location_city,
                                    enabled: _selectedCountry != null,
                                    onTap: () {
                                      final states = _stateCache[
                                              _selectedCountry!.isoCode] ??
                                          [];
                                      _openPickerSheet(
                                        title: 'Select State',
                                        subtitle:
                                            'Choose your state from ${_selectedCountry!.name}',
                                        items:
                                            states.map((s) => s.name).toList(),
                                        onSelected: (selected) async {
                                          final state = states.firstWhere(
                                              (s) => s.name == selected);
                                          setState(() {
                                            _selectedState = state;
                                            _stateController.text = state.name;
                                            _selectedCity = null;
                                            _cityController.clear();
                                          });

                                          // Load cities with caching
                                          if (!_cityCache
                                              .containsKey(state.isoCode)) {
                                            final cities =
                                                await _dataService.loadCities();
                                            _cityCache[state.isoCode] = cities
                                                .where((c) =>
                                                    c.stateCode ==
                                                    state.isoCode)
                                                .toList();
                                          }
                                          setState(() {});
                                        },
                                      );
                                    },
                                    validator: (value) {
                                      if (_selectedCountry == null)
                                        return 'Select a country first';
                                      return value?.isEmpty ?? true
                                          ? 'Please select a state'
                                          : null;
                                    },
                                  ),
                                  _buildLocationField(
                                    label: 'City',
                                    hint: 'Select your city',
                                    controller: _cityController,
                                    icon: Icons.location_on,
                                    enabled: _selectedState != null,
                                    onTap: () {
                                      final cities =
                                          _cityCache[_selectedState!.isoCode] ??
                                              [];
                                      _openPickerSheet(
                                        title: 'Select City',
                                        subtitle:
                                            'Choose your city from ${_selectedState!.name}',
                                        items:
                                            cities.map((c) => c.name).toList(),
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedCity = cities.firstWhere(
                                                (c) => c.name == selected);
                                            _cityController.text =
                                                _selectedCity!.name;
                                          });
                                        },
                                      );
                                    },
                                    validator: (value) {
                                      if (_selectedState == null)
                                        return 'Select a state first';
                                      return value?.isEmpty ?? true
                                          ? 'Please select a city'
                                          : null;
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          HapticFeedback.mediumImpact();
                          _showSnackbar(
                              'Location set to: ${_selectedCity?.name}, '
                              '${_selectedState?.name}, ${_selectedCountry?.name}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor:
                            Theme.of(context).primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> items;
  final Function(String) onSelected;

  const _LocationPickerSheet({
    required this.title,
    required this.items,
    required this.onSelected,
    this.subtitle,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _filterItems,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredItems[index]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelected(_filteredItems[index]);
                    Navigator.pop(context);
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
