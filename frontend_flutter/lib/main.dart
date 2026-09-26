import 'package:flutter/material.dart';
import 'screens/customer_order_screen.dart';
import 'widgets/floating_food_overlay.dart';

// Global ValueNotifier cho Dark/Light Mode
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

// Global Cart notifier — dùng chung giữa các screens
final ValueNotifier<List<dynamic>> cartNotifier = ValueNotifier([]);

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Ramen House — Order Menu',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Light Theme — Figma White
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA81E22),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F8F8),
            fontFamily: 'Urbanist',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF080808),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),

          // Dark Theme — Figma Dark #080808
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA81E22),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF080808),
            fontFamily: 'Urbanist',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF080808),
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),

          builder: (context, child) {
            return Stack(
              children: [
                ?child,
                const Positioned.fill(
                  child: GlobalFloatingFoodOverlay(),
                ),
              ],
            );
          },

          home: const CustomerOrderScreen(),
        );
      },
    );
  }
}
