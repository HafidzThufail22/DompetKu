import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data untuk format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

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
        // THEME DATA - DARK THEME
        // ============================================================
        theme: ThemeData(
          // Menggunakan Material 3
          useMaterial3: true,

          // Brightness
          brightness: Brightness.dark,

          // Scaffold Background
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),

          // Color Scheme - Dark with Lime Green Accent
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFC6FF00),         // Lime Green
            secondary: Color(0xFFC6FF00),       // Lime Green
            surface: Color(0xFF1A1A1A),         // Dark card
            error: Color(0xFFFF5252),           // Red
            onPrimary: Color(0xFF0D0D0D),       // Text on lime green
            onSecondary: Color(0xFF0D0D0D),
            onSurface: Colors.white,
            onError: Colors.white,
          ),

          // App Bar Theme
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF0D0D0D),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // Card Theme
          cardTheme: CardThemeData(
            elevation: 0,
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC6FF00),
              foregroundColor: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC6FF00),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: const TextStyle(color: Color(0xFF666666)),
            prefixIconColor: const Color(0xFF9E9E9E),
          ),

          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFC6FF00),
            foregroundColor: Color(0xFF0D0D0D),
            elevation: 4,
          ),

          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            selectedItemColor: Color(0xFFC6FF00),
            unselectedItemColor: Color(0xFF666666),
          ),

          // Snackbar Theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF1A1A1A),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Dialog Theme
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // ============================================================
        // MAIN SCREEN WITH BOTTOM NAVIGATION
        // ============================================================
        home: const MainScreen(),
      ),
    );
  }
}

// ============================================================
// HELPER CLASS UNTUK WARNA KUSTOM - DARK THEME
// ============================================================
/// Class untuk menyimpan konstanta warna aplikasi
/// Tema: Dark Mode dengan aksen Lime Green
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors - Lime Green Accent
  static const Color primary = Color(0xFFC6FF00);       // Lime Green
  static const Color primaryLight = Color(0xFFE4FF54);  // Lime Green Light
  static const Color primaryDark = Color(0xFF9ECC00);   // Lime Green Dark

  // Income & Expense Colors
  static const Color income = Color(0xFFC6FF00);        // Lime Green untuk pemasukan
  static const Color incomeLight = Color(0xFF1A2E1A);   // Dark green background
  static const Color expense = Color(0xFFFF5252);       // Merah terang
  static const Color expenseLight = Color(0xFF2E1A1A); // Dark red background

  // Dark Theme Background Colors
  static const Color background = Color(0xFF0D0D0D);    // Almost black
  static const Color surface = Color(0xFF1A1A1A);       // Dark gray card
  static const Color surfaceLight = Color(0xFF242424);  // Slightly lighter card
  static const Color cardBackground = Color(0xFF1E1E1E); // Card background

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);   // White
  static const Color textSecondary = Color(0xFF9E9E9E); // Gray
  static const Color textMuted = Color(0xFF666666);     // Muted gray

  // Other Colors
  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF333333);
}
