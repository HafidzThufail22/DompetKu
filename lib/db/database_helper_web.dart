// Dummy database helper untuk platform Web
// sqflite tidak support web, jadi kita buat dummy class

/// Dummy DatabaseHelper untuk Web
/// Tidak melakukan apa-apa, hanya placeholder
class DatabaseHelper {
  // Singleton pattern (dummy)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
}
