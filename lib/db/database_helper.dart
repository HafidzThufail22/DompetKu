import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

/// Database Helper dengan pola Singleton
/// Mengelola semua operasi database (CRUD) untuk tabel transactions
class DatabaseHelper {
  // ============================================================
  // SINGLETON PATTERN
  // ============================================================

  /// Instance private static
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  /// Factory constructor yang mengembalikan instance yang sama
  factory DatabaseHelper() => _instance;

  /// Private named constructor
  DatabaseHelper._internal();

  // ============================================================
  // DATABASE CONFIGURATION
  // ============================================================

  /// Instance database (nullable, akan diinisialisasi saat pertama kali diakses)
  static Database? _database;

  /// Nama file database
  static const String _databaseName = 'dompetku.db';

  /// Versi database (untuk migrasi di masa depan)
  static const int _databaseVersion = 1;

  /// Nama tabel
  static const String tableName = 'transactions';

  // ============================================================
  // DATABASE GETTER
  // ============================================================

  /// Getter untuk database instance
  /// Jika belum ada, akan menginisialisasi database terlebih dahulu
  Future<Database> get database async {
    // Jika database sudah diinisialisasi, langsung return
    if (_database != null) return _database!;

    // Jika belum, inisialisasi dulu
    _database = await _initDB();
    return _database!;
  }

  // ============================================================
  // INISIALISASI DATABASE
  // ============================================================

  /// Menginisialisasi dan membuka database
  /// Jika database belum ada, akan membuat tabel baru
  Future<Database> _initDB() async {
    // Mendapatkan path direktori database
    String databasesPath = await getDatabasesPath();

    // Menggabungkan path dengan nama file database
    String path = join(databasesPath, _databaseName);

    // Membuka database (atau membuat jika belum ada)
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Callback saat database pertama kali dibuat
  /// Membuat tabel 'transactions' dengan skema yang sudah ditentukan
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // CRUD OPERATIONS
  // ============================================================

  /// INSERT: Menambahkan transaksi baru ke database
  /// Returns: ID dari transaksi yang baru ditambahkan
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;

    // Insert dan return ID yang di-generate
    return await db.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ: Mengambil semua transaksi dari database
  /// Data diurutkan berdasarkan tanggal terbaru (DESC)
  /// Returns: List of Transaction objects
  Future<List<Transaction>> getTransactionList() async {
    final db = await database;

    // Query semua data, urutkan dari tanggal terbaru
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'date DESC, id DESC', // Urutkan tanggal DESC, lalu ID DESC
    );

    // Konversi List<Map> ke List<Transaction>
    return List.generate(maps.length, (index) {
      return Transaction.fromMap(maps[index]);
    });
  }

  /// DELETE: Menghapus transaksi berdasarkan ID
  /// Returns: Jumlah baris yang terhapus (1 jika sukses, 0 jika tidak ditemukan)
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // UTILITY METHODS (BONUS)
  // ============================================================

  /// Menghitung total saldo (Pemasukan - Pengeluaran)
  /// Returns: Total saldo dalam Integer
  Future<int> getTotalBalance() async {
    final db = await database;

    // Hitung total pemasukan
    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $tableName 
      WHERE type = ${Transaction.typeIncome}
    ''');
    final totalIncome = incomeResult.first['total'] as int;

    // Hitung total pengeluaran
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $tableName 
      WHERE type = ${Transaction.typeExpense}
    ''');
    final totalExpense = expenseResult.first['total'] as int;

    // Return selisih
    return totalIncome - totalExpense;
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
