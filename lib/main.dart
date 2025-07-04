import 'package:finanzas/presentation/auth/pages/login.dart';
import 'package:finanzas/presentation/auth/pages/register.dart';
import 'package:finanzas/presentation/auth/services/auth_services.dart';
import 'package:finanzas/blocs/auth/auth_bloc.dart';
import 'package:finanzas/presentation/home/pages/home_screen.dart';
import 'package:finanzas/presentation/see_finance/pages/see_finance_screen.dart';
import 'package:finanzas/shared/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final userId = snapshot.data!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(authService: AuthService()),
            ),
          ],
          child: MaterialApp(
            title: 'Finanzas TF App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.red, surface: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: AppColors.lightGray, width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: AppColors.colorGray, width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.red, width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            initialRoute: userId.isNotEmpty ? '/home' : '/login',
            onGenerateRoute: (settings) {
              if (settings.name == '/see-finance') {
                final args = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) =>
                      SeeFinanceScreen(recordId: args),
                );
              }

              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/register':
                  return MaterialPageRoute(builder: (_) => const RegisterScreen());
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                default:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Ruta no encontrada')),
                    ),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
