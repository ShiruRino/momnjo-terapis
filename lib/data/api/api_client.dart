import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  factory ApiClient({http.Client? client}) {
    if (client != null) {
      instance.setClient(client);
    }
    return instance;
  }

  ApiClient._internal([http.Client? client]) : _client = client ?? http.Client();

  http.Client _client;

  void setClient(http.Client client) {
    _client = client;
  }

  String? _token;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(extraHeaders: headers))
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'Koneksi internet bermasalah. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message: 'Waktu koneksi ke server habis (Timeout). Silakan coba lagi.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Terjadi kendala jaringan: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .post(uri, headers: _buildHeaders(extraHeaders: headers), body: encodedBody)
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'Koneksi internet bermasalah. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message: 'Waktu koneksi ke server habis (Timeout). Silakan coba lagi.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Terjadi kendala jaringan: $e');
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    String fullUrl = '${ApiConfig.baseUrl}$endpoint';
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final mappedParams = queryParameters.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      )..removeWhere((key, value) => value.isEmpty);
      return Uri.parse(fullUrl).replace(queryParameters: mappedParams);
    }
    return Uri.parse(fullUrl);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> body = {};

    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      body = {
        'status': false,
        'message': response.body.isNotEmpty ? response.body : 'Format respons server tidak valid',
      };
    }

    if (statusCode >= 200 && statusCode < 300) {
      final isStatusSuccess = body['status'] == true;
      if (!isStatusSuccess) {
        throw ApiException(
          statusCode: statusCode,
          message: body['message'] ?? 'Operasi gagal',
          data: body['data'],
        );
      }
      return body;
    } else {
      final message = body['message'] ?? 'Terjadi kesalahan pada sistem (HTTP $statusCode)';
      throw ApiException(
        statusCode: statusCode,
        message: message,
        data: body['data'],
      );
    }
  }
}
