import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PortfolioApi extends ChangeNotifier {
  PortfolioApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _base = Uri.parse(
        baseUrl ??
            const String.fromEnvironment(
              'DJANGO_BASE_URL',
              defaultValue: 'http://localhost:8000',
            ),
      );

  final http.Client _client;
  final Uri _base;
  String? _token;
  bool get signedIn => _token != null;
  bool _canWrite = false;
  bool get canWrite => _canWrite;
  bool _signingOut = false;
  bool get signingOut => _signingOut;

  Future<dynamic> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final request = http.Request(method, _base.resolve(path));
    request.followRedirects = false;
    request.headers['Accept'] = 'application/json';
    if (_token case final token?) {
      request.headers['Authorization'] = 'Token $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 204) return null;
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      if (data is Map) {
        final message = data['message'] ?? data['detail'];
        if (message is String) throw ApiException(message);
        final errors = data.entries.where((entry) => entry.value is List);
        if (errors.isNotEmpty) {
          throw ApiException(
            errors
                .map(
                  (entry) => '${entry.key}: ${(entry.value as List).join(' ')}',
                )
                .join('\n'),
          );
        }
      }
      throw ApiException('Permintaan gagal (${response.statusCode}).');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException('Tidak bisa menghubungi server Django.');
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    }
  }

  Future<void> login(String username, String password) async {
    final data = await _send('POST', '/auth/login/', {
      'username': username,
      'password': password,
    });
    if (data is! Map ||
        data['token'] is! String ||
        (data['token'] as String).isEmpty) {
      throw const ApiException('Respons login tidak valid.');
    }
    _token = data['token'] as String;
    _canWrite = data['can_write'] == true;
    notifyListeners();
  }

  Future<void> register(
    String username,
    String password,
    String confirmation,
  ) async {
    await _send('POST', '/auth/register/', {
      'username': username,
      'password1': password,
      'password2': confirmation,
    });
  }

  Future<void> logout() async {
    if (_signingOut) return;
    _signingOut = true;
    notifyListeners();
    try {
      await _send('POST', '/auth/logout/', {});
      _token = null;
      _canWrite = false;
    } finally {
      _signingOut = false;
      notifyListeners();
    }
  }

  Future<List<Project>> listProjects() async {
    final data = await _send('GET', '/api/v1/projects/') as List;
    return data
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> getProject(int id) async {
    final data = await _send('GET', '/api/v1/projects/$id/');
    return Project.fromJson(data as Map<String, dynamic>);
  }

  Future<void> createProject(Map<String, dynamic> payload) async {
    await _send('POST', '/api/v1/projects/', payload);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
