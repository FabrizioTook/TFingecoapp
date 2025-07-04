import 'dart:convert';
import 'package:finanzas/shared/api/api_config.dart';
import 'package:finanzas/shared/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = ApiService.baseUrl;

  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['detail']);
    }
  }
}