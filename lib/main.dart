import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ============================================================
      // PROVIDERS SETUP
      // ============================================================
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        // Tambahkan provider lain di sini jika diperlukan
      ],

      // ============================================================
      // MATERIAL APP
      // ============================================================
      child: MaterialApp(
        title: 'DompetKu',
        debugShowCheckedModeBanner: false,

        // ============================================================
        // THEME DATA
        // ============================================================
        theme: ThemeData(
          // Menggunakan Material 3
          useMaterial3: true,

          // Color Scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ).copyWith(
            // Custom colors untuk aplikasi
            primary: const Color(0xFF2196F3),       // Biru - Primary
            secondary: const Color(0xFF4CAF50),     // Hijau - Income
            error: const Color(0xFFF44336),         // Merah - Expense
            surface: Colors.white,
            onSurface: Colors.black87,
          ),

          // App Bar Theme
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Card Theme
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),

          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2196F3),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ),

        // ============================================================
        // HOME SCREEN
        // ============================================================
        home: const HomeScreen(),
      ),
    );
  }
}

// ============================================================
// HELPER CLASS UNTUK WARNA KUSTOM
// ============================================================
/// Class untuk menyimpan konstanta warna aplikasi
/// Digunakan di seluruh aplikasi untuk konsistensi
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Income & Expense Colors
  static const Color income = Color(0xFF4CAF50);      // Hijau
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFF44336);     // Merah
  static const Color expenseLight = Color(0xFFFFEBEE);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}
