import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenSubtitlesApi {
  static const String _baseUrl = 'https://api.opensubtitles.com/api/v1';
  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<String?> _getApiKey() async {
    return await _storage.read(key: 'opensubtitles_api_key');
  }

  Future<String?> _getUserAgent() async {
    return await _storage.read(key: 'opensubtitles_user_agent');
  }

  Future<Map<String, String>> _getHeaders() async {
    final apiKey = await _getApiKey();
    final userAgent = await _getUserAgent();
    final headers = {
      'Content-Type': 'application/json',
      'Api-Key': apiKey ?? '',
      'X-User-Agent': userAgent ?? '',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> login() async {
    final username = await _storage.read(key: 'opensubtitles_username');
    final password = await _storage.read(key: 'opensubtitles_password');

    if (username == null || password == null) {
      return;
    }

    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: headers,
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<List<dynamic>> searchSubtitles(String movieName, String language) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/subtitles?query=$movieName&languages=$language'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load subtitles');
    }
  }

  Future<String> downloadSubtitle(int fileId) async {
    if (_token == null) {
      await login();
    }

    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/download'),
      headers: headers,
      body: json.encode({
        'file_id': fileId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final downloadUrl = data['link'];
      final downloadResponse = await http.get(Uri.parse(downloadUrl));
      if (downloadResponse.statusCode == 200) {
        return downloadResponse.body;
      } else {
        throw Exception('Failed to download subtitle content');
      }
    } else {
      throw Exception('Failed to get download link');
    }
  }
}
