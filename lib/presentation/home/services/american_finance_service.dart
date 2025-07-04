import 'dart:convert';
import 'package:finanzas/shared/api/api_config.dart';
import 'package:finanzas/shared/models/finance_input.dart';
import 'package:http/http.dart' as http;

class AmericanFinanceService {
  final String baseUrl = ApiService.baseUrl; // Cambia esto a tu URL base

  Future<FinanceInput> createRecord(FinanceInput financeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/american'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(financeData.toJson()),
    );

    if (response.statusCode == 200) {
      return FinanceInput.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<List<FinanceInput>> getRecords({String? userId, String? recordId}) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (recordId != null) queryParams['registro_id'] = recordId;

    final uri = Uri.parse('$baseUrl/american').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => FinanceInput.fromJson(item)).toList();
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<FinanceInput> updateRecord(String recordId, FinanceInput updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/american/$recordId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData.toJson()),
    );

    if (response.statusCode == 200) {
      return FinanceInput.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<Map<String, dynamic>> deleteRecord(String recordId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/american/$recordId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }
}
