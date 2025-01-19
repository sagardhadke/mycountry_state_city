import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/country.dart';
import '../models/state.dart';
import '../models/city.dart';

class DataService {
  Future<List<Country>> loadCountries() async {
    final String response = await rootBundle.loadString('assets/country_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Country.fromJson(json)).toList();
  }

  Future<List<State>> loadStates() async {
    final String response = await rootBundle.loadString('assets/state_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => State.fromJson(json)).toList();
  }

  Future<List<City>> loadCities() async {
    final String response = await rootBundle.loadString('assets/city_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => City.fromJson(json)).toList();
  }
}