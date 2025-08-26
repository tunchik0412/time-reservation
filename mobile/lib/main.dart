import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'presentation/navigation/main_navigation.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/providers/reservation_provider.dart';
import 'core/config/app_config.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  // You can change this to 'production' when building for release
  await AppConfig.initialize(environment: 'development');
  
  // Print configuration for debugging
  AppConfig.printConfig();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: 'Time Reservation',
                theme: _buildTheme(appProvider.isDarkMode),
                darkTheme: _buildDarkTheme(),
                themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                onGenerateRoute: AppRouter.generateRoute,
                home: authProvider.isAuthenticated 
                    ? const MainNavigation() 
                    : const AuthWrapper(),
                initialRoute: authProvider.isAuthenticated ? '/home' : '/login',
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(bool isDarkMode) {
    // Platform-specific theme
    if (Platform.isIOS) {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? Colors.blue.shade800 : Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0, // iOS style flat design
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // iOS rounded buttons
            ),
          ),
        ),
      );
    } else {
      // Android Material Design
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? Colors.deepPurple.shade800 : Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4, // Android shadow
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Android style
            ),
          ),
        ),
      );
    }
  }

  ThemeData _buildDarkTheme() {
    return _buildTheme(true);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const MainNavigation();
        } else {
          // Start with login page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}