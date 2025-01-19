import 'package:flutter/material.dart';
import 'package:mycountry_state_city/models/city.dart';
import 'package:mycountry_state_city/models/country.dart';
import 'package:mycountry_state_city/models/state.dart' as myState;
import 'package:mycountry_state_city/services/data_service.dart';

class MyCountryPick extends StatefulWidget {
  const MyCountryPick({super.key});

  @override
  State<MyCountryPick> createState() => _MyCountryPickState();
}

class _MyCountryPickState extends State<MyCountryPick> {
  final DataService dataService = DataService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Country> countries = [];
  List<myState.State> states = [];
  List<City> cities = [];

  Country? selectedCountry;
  myState.State? selectedState;
  City? selectedCity;

  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dataService.loadCountries().then((data) {
      setState(() {
        countries = data;
      });
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openPickerDialog({
    required String title,
    required List<String> items,
    required Function(String) onItemSelected,
  }) async {
    String searchQuery = '';
    List<String> filteredItems = items;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: EdgeInsets.zero,
              content: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Search...',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase();
                                    filteredItems = items
                                        .where((item) => item.toLowerCase().contains(searchQuery))
                                        .toList();
                                  });
                                },
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  onItemSelected(filteredItems[index]);
                                  _formKey.currentState!.validate();
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                  child: Text(
                                    filteredItems[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCountryPicker() {
    _openPickerDialog(
      title: 'Select Country',
      items: countries.map((country) => country.name).toList(),
      onItemSelected: (selected) {
        setState(() {
          selectedCountry = countries.firstWhere((country) => country.name == selected);
          countryController.text = selectedCountry!.name;
          selectedState = null;
          selectedCity = null;
          stateController.clear();
          cityController.clear();
          states = [];
          cities = [];
          dataService.loadStates().then((data) {
            setState(() {
              states = data.where((myState.State state) => state.countryCode == selectedCountry!.isoCode).toList();
            });
          });
        });
      },
    );
  }

  void _openStatePicker() {
    if (selectedCountry == null) {
      _showSnackbar('Please select a country first');
      return;
    }
    _openPickerDialog(
      title: 'Select State',
      items: states.map((state) => state.name).toList(),
      onItemSelected: (selected) {
        setState(() {
          selectedState = states.firstWhere((state) => state.name == selected);
          stateController.text = selectedState!.name;
          selectedCity = null;
          cityController.clear();
          cities = [];
          dataService.loadCities().then((data) {
            setState(() {
              cities = data.where((city) => city.stateCode == selectedState!.isoCode).toList();
            });
          });
        });
      },
    );
  }

  void _openCityPicker() {
    if (selectedCountry == null) {
      _showSnackbar('Please select a country first');
      return;
    }
    if (selectedState == null) {
      _showSnackbar('Please select a state first');
      return;
    }
    _openPickerDialog(
      title: 'Select City',
      items: cities.map((city) => city.name).toList(),
      onItemSelected: (selected) {
        setState(() {
          selectedCity = cities.firstWhere((city) => city.name == selected);
          cityController.text = selectedCity!.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country-State-City Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _openCountryPicker,
                  ),
                ),
                controller: countryController,
                onTap: _openCountryPicker,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _openStatePicker,
                  ),
                ),
                controller: stateController,
                onTap: _openStatePicker,
                validator: (value) {
                  if (selectedCountry == null) {
                    return 'Please select a country first';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _openCityPicker,
                  ),
                ),
                controller: cityController,
                onTap: _openCityPicker,
                validator: (value) {
                  if (selectedCountry == null) {
                    return 'Please select a country first';
                  }
                  if (selectedState == null) {
                    return 'Please select a state first';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSnackbar('All selections are valid!');
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}