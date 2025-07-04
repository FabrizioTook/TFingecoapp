import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_result.dart';

class ApiService {
  static const String baseUrl = "https://bonos-finanzas.vercel.app/api";

  static Future<ApiResult<dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: queryParameters);
      final response = await http.get(uri);
      return _processResponse(response);
    } catch (e) {
      return ApiResult.failure('GET error: $e');
    }
  }

  static Future<ApiResult<dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      return ApiResult.failure('POST error: $e');
    }
  }

  static Future<ApiResult<dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      return ApiResult.failure('PUT error: $e');
    }
  }

  static Future<ApiResult<dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri);
      return _processResponse(response);
    } catch (e) {
      return ApiResult.failure('DELETE error: $e');
    }
  }

  static ApiResult<dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        return ApiResult.success(decoded);
      } catch (_) {
        return ApiResult.success({'message': 'Empty or invalid JSON'});
      }
    } else {
      return ApiResult.failure(
          'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}');
    }
  }
}
