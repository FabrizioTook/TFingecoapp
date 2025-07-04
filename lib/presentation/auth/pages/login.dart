import 'package:finanzas/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas/blocs/auth/auth_bloc.dart';
import 'package:finanzas/blocs/auth/auth_event.dart';
import 'package:finanzas/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _login() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  void _showErrorDialog(String message) {
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
    if (value == null || value.isEmpty) {
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
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoading) {
                  setState(() {
                    isLoading = true;
                  });
                } else if (state is AuthSuccess) {
                  setState(() {
                    isLoading = false;
                  });
                  _onLoginSuccess(state.user);
                } else if (state is AuthFailure) {
                  setState(() {
                    isLoading = false;
                  });
                  _showErrorDialog(state.error);
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return isLoading
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
                                  'Iniciar sesión',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(labelText: 'Email'),
                                  textInputAction: TextInputAction.next,
                                  validator: validator,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration:
                                      InputDecoration(labelText: 'Contraseña'),
                                  obscureText: true,
                                  validator: validator,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _login,
                                  child: Text(
                                    'Iniciar sesión',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
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
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "¿No tienes cuenta? Regístrate aquí",
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _onLoginSuccess(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', user.id);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
