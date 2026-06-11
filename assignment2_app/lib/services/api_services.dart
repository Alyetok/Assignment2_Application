// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/homestay.dart';

class ApiService {
  /// Fetch all homestays, optionally filtered by [state], [district],
  /// or a search [keyword]. Pass [limit] to cap the number of results.
  static Future<List<Homestay>> fetchHomestays({
    String? keyword,
    String? state,
    String? district,
    int? limit,
  }) async {
    final uri = _buildUri('/homestays', {
      if (keyword != null && keyword.isNotEmpty) 'search': keyword,
      if (state != null && state.isNotEmpty) 'state': state,
      if (district != null && district.isNotEmpty) 'district': district,
      if (limit != null) 'limit': limit.toString(),
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // The API may return either a List or a Map with a data key
        List<dynamic> raw;
        if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          raw = decoded['data'] as List<dynamic>;
        } else if (decoded is Map && decoded.containsKey('homestays')) {
          raw = decoded['homestays'] as List<dynamic>;
        } else {
          raw = [];
        }

        return raw
            .map((item) => Homestay.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Unable to reach the server. Please try again later.');
    } on FormatException {
      throw Exception('Unexpected data format from server.');
    }
  }

  /// Fetch the list of available states from the API.
  static Future<List<String>> fetchStates() async {
    final uri = _buildUri('/states', {});

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> raw;
        if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          raw = decoded['data'] as List<dynamic>;
        } else if (decoded is Map && decoded.containsKey('states')) {
          raw = decoded['states'] as List<dynamic>;
        } else {
          raw = [];
        }

        // Each item may be a String or a Map with a 'state'/'name' key
        return raw.map((item) {
          if (item is String) return item;
          if (item is Map) {
            return (item['state'] ?? item['name'] ?? item.values.first)
                .toString();
          }
          return item.toString();
        }).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Unable to reach the server.');
    } on FormatException {
      throw Exception('Unexpected data format from server.');
    }
  }

  static Uri _buildUri(String path, Map<String, String> params) {
    // The base URL uses http (not https) so we use Uri.http
    const host = 'slum78.myddns.me';
    return Uri.http(
      host,
      '/homestay2u/api$path',
      params.isEmpty ? null : params,
    );
  }
}
