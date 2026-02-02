import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Database Helper dengan pola Singleton
/// Mengelola semua operasi database (CRUD) untuk tabel transactions dan categories
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

  /// Versi database (untuk migrasi)
  static const int _databaseVersion = 3;

  /// Nama tabel
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';

  // ============================================================
  // DATABASE GETTER
  // ============================================================

  /// Getter untuk database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ============================================================
  // INISIALISASI DATABASE
  // ============================================================

  /// Menginisialisasi dan membuka database
  Future<Database> _initDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Callback saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    // Buat tabel categories terlebih dahulu
    await db.execute('''
      CREATE TABLE $tableCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type INTEGER NOT NULL
      )
    ''');

    // Buat tabel transactions dengan foreign key ke categories
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        wallet_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES $tableCategories(id)
      )
    ''');

    // Seed default categories
    await _seedDefaultCategories(db);
  }

  /// Callback saat database di-upgrade dari versi lama
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrasi dari versi 1 ke versi 2

      // 1. Buat tabel categories baru
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableCategories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type INTEGER NOT NULL
        )
      ''');

      // 2. Seed default categories
      await _seedDefaultCategories(db);

      // 3. Buat tabel transactions baru dengan skema baru
      await db.execute('''
        CREATE TABLE ${tableTransactions}_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES $tableCategories(id)
        )
      ''');

      // 4. Migrasi data dari tabel lama ke tabel baru
      // Mapping: type 1 (income) -> category_id 3 (Gaji), type 0 (expense) -> category_id 1 (Makan)
      await db.execute('''
        INSERT INTO ${tableTransactions}_new (id, title, amount, category_id, date)
        SELECT id, title, amount, 
          CASE WHEN type = 1 THEN 3 ELSE 1 END as category_id,
          date
        FROM $tableTransactions
      ''');

      // 5. Hapus tabel lama
      await db.execute('DROP TABLE $tableTransactions');

      // 6. Rename tabel baru
      await db.execute(
        'ALTER TABLE ${tableTransactions}_new RENAME TO $tableTransactions',
      );
    }

    if (oldVersion < 3) {
      // Migrasi dari versi 2 ke versi 3 - Tambah kolom wallet_id
      await db.execute(
        'ALTER TABLE $tableTransactions ADD COLUMN wallet_id INTEGER',
      );
    }
  }

  /// Seed default categories
  Future<void> _seedDefaultCategories(Database db) async {
    // Expense categories
    await db.insert(tableCategories, {
      'name': 'Makan',
      'type': Category.typeExpense,
    });
    await db.insert(tableCategories, {
      'name': 'Transport',
      'type': Category.typeExpense,
    });

    // Income categories
    await db.insert(tableCategories, {
      'name': 'Gaji',
      'type': Category.typeIncome,
    });
    await db.insert(tableCategories, {
      'name': 'Bonus',
      'type': Category.typeIncome,
    });
    await db.insert(tableCategories, {
      'name': 'Freelance',
      'type': Category.typeIncome,
    });

    // More expense categories
    await db.insert(tableCategories, {
      'name': 'Belanja',
      'type': Category.typeExpense,
    });
    await db.insert(tableCategories, {
      'name': 'Hiburan',
      'type': Category.typeExpense,
    });
    await db.insert(tableCategories, {
      'name': 'Tagihan',
      'type': Category.typeExpense,
    });
    await db.insert(tableCategories, {
      'name': 'Kesehatan',
      'type': Category.typeExpense,
    });
    await db.insert(tableCategories, {
      'name': 'Lainnya',
      'type': Category.typeExpense,
    });
  }

  // ============================================================
  // CRUD OPERATIONS - CATEGORIES
  // ============================================================

  /// INSERT: Menambahkan kategori baru
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ: Mengambil semua kategori
  Future<List<Category>> getCategoryList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      orderBy: 'type DESC, name ASC', // Income dulu, lalu expense, urutkan nama
    );
    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  /// READ: Mengambil kategori berdasarkan tipe
  Future<List<Category>> getCategoriesByType(int type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (index) {
      return Category.fromMap(maps[index]);
    });
  }

  /// READ: Mengambil kategori berdasarkan ID
  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// UPDATE: Mengubah kategori
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// DELETE: Menghapus kategori berdasarkan ID
  /// Perhatian: Pastikan tidak ada transaksi yang menggunakan kategori ini
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // CRUD OPERATIONS - TRANSACTIONS
  // ============================================================

  /// INSERT: Menambahkan transaksi baru
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert(
      tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ: Mengambil semua transaksi dengan JOIN ke kategori
  /// Data diurutkan berdasarkan tanggal terbaru (DESC)
  Future<List<Transaction>> getTransactionList() async {
    final db = await database;

    // Query dengan JOIN untuk mendapatkan data kategori
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.category_id,
        t.date,
        t.wallet_id,
        c.name as category_name,
        c.type as category_type
      FROM $tableTransactions t
      LEFT JOIN $tableCategories c ON t.category_id = c.id
      ORDER BY t.date DESC, t.id DESC
    ''');

    return List.generate(maps.length, (index) {
      return Transaction.fromMapWithCategory(maps[index]);
    });
  }

  /// READ: Mengambil transaksi berdasarkan tipe kategori
  Future<List<Transaction>> getTransactionsByType(int type) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.category_id,
        t.date,
        t.wallet_id,
        c.name as category_name,
        c.type as category_type
      FROM $tableTransactions t
      LEFT JOIN $tableCategories c ON t.category_id = c.id
      WHERE c.type = ?
      ORDER BY t.date DESC, t.id DESC
    ''',
      [type],
    );

    return List.generate(maps.length, (index) {
      return Transaction.fromMapWithCategory(maps[index]);
    });
  }

  /// READ: Mengambil transaksi berdasarkan kategori
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.category_id,
        t.date,
        t.wallet_id,
        c.name as category_name,
        c.type as category_type
      FROM $tableTransactions t
      LEFT JOIN $tableCategories c ON t.category_id = c.id
      WHERE t.category_id = ?
      ORDER BY t.date DESC, t.id DESC
    ''',
      [categoryId],
    );

    return List.generate(maps.length, (index) {
      return Transaction.fromMapWithCategory(maps[index]);
    });
  }

  /// READ: Mengambil transaksi berdasarkan rentang tanggal
  Future<List<Transaction>> getTransactionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.category_id,
        t.date,
        t.wallet_id,
        c.name as category_name,
        c.type as category_type
      FROM $tableTransactions t
      LEFT JOIN $tableCategories c ON t.category_id = c.id
      WHERE t.date >= ? AND t.date <= ?
      ORDER BY t.date DESC, t.id DESC
    ''',
      [startDate, endDate],
    );

    return List.generate(maps.length, (index) {
      return Transaction.fromMapWithCategory(maps[index]);
    });
  }

  /// UPDATE: Mengubah transaksi
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// DELETE: Menghapus transaksi berdasarkan ID
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Menghitung total saldo (Pemasukan - Pengeluaran)
  Future<int> getTotalBalance() async {
    final db = await database;

    // Hitung total pemasukan
    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(t.amount), 0) as total 
      FROM $tableTransactions t
      JOIN $tableCategories c ON t.category_id = c.id
      WHERE c.type = ${Category.typeIncome}
    ''');
    final totalIncome = incomeResult.first['total'] as int;

    // Hitung total pengeluaran
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(t.amount), 0) as total 
      FROM $tableTransactions t
      JOIN $tableCategories c ON t.category_id = c.id
      WHERE c.type = ${Category.typeExpense}
    ''');
    final totalExpense = expenseResult.first['total'] as int;

    return totalIncome - totalExpense;
  }

  /// Menghitung total pemasukan
  Future<int> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(t.amount), 0) as total 
      FROM $tableTransactions t
      JOIN $tableCategories c ON t.category_id = c.id
      WHERE c.type = ${Category.typeIncome}
    ''');
    return result.first['total'] as int;
  }

  /// Menghitung total pengeluaran
  Future<int> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(t.amount), 0) as total 
      FROM $tableTransactions t
      JOIN $tableCategories c ON t.category_id = c.id
      WHERE c.type = ${Category.typeExpense}
    ''');
    return result.first['total'] as int;
  }

  /// Mendapatkan statistik per kategori
  Future<List<Map<String, dynamic>>> getCategoryStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.type,
        COALESCE(SUM(t.amount), 0) as total,
        COUNT(t.id) as count
      FROM $tableCategories c
      LEFT JOIN $tableTransactions t ON c.id = t.category_id
      GROUP BY c.id
      ORDER BY total DESC
    ''');
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  /// Reset database (untuk testing)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(tableTransactions);
    await db.delete(tableCategories);
    await _seedDefaultCategories(db);
  }
}
