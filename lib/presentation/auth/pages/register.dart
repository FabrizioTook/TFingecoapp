import 'dart:developer';

import 'package:finanzas/presentation/auth/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // Servicio de autenticación
  bool isLoading = false;

  Future<void> _register() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => isLoading = true);

    try {
      final result = await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Guardar ID en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', result.id);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    log(message);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error de inicio de sesión'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo no puede estar vacío';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        body: Center(
          child: SingleChildScrollView(
            child: isLoading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Form(
                      key: formKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          Image.asset(
                            'assets/upc.png',
                            width: 100,
                            height: 100,
                          ),
                          Text(
                            'Finanzas TF',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Registrarse',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Nombre'),
                            textInputAction: TextInputAction.next,
                            validator: validator,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                            textInputAction: TextInputAction.next,
                            validator: validator,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(labelText: 'Contraseña'),
                            obscureText: true,
                            validator: validator,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _register,
                            child: Text('Registrarse'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        bottomNavigationBar: isLoading
            ? null
            : SafeArea(
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text("¿Ya tienes cuenta? Inicia sesión"),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
