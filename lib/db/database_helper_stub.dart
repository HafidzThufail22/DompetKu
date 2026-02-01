// Stub database helper untuk platform Web
// File ini digunakan saat aplikasi berjalan di web browser

import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Stub DatabaseHelper untuk Web
/// Semua method mengembalikan nilai kosong/default karena tidak ada database di web
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Table names (untuk konsistensi dengan versi mobile)
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';

  // ============================================================
  // CATEGORY STUB METHODS
  // ============================================================

  Future<int> insertCategory(Category category) async => 0;
  Future<List<Category>> getCategoryList() async => _getDefaultCategories();
  Future<List<Category>> getCategoriesByType(int type) async {
    return _getDefaultCategories().where((c) => c.type == type).toList();
  }
  Future<Category?> getCategoryById(int id) async {
    final categories = _getDefaultCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
  Future<int> updateCategory(Category category) async => 0;
  Future<int> deleteCategory(int id) async => 0;

  // ============================================================
  // TRANSACTION STUB METHODS
  // ============================================================

  Future<int> insertTransaction(Transaction transaction) async => 0;
  Future<List<Transaction>> getTransactionList() async => [];
  Future<List<Transaction>> getTransactionsByType(int type) async => [];
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async => [];
  Future<List<Transaction>> getTransactionsByDateRange(String startDate, String endDate) async => [];
  Future<int> updateTransaction(Transaction transaction) async => 0;
  Future<int> deleteTransaction(int id) async => 0;

  // ============================================================
  // UTILITY STUB METHODS
  // ============================================================

  Future<int> getTotalBalance() async => 0;
  Future<int> getTotalIncome() async => 0;
  Future<int> getTotalExpense() async => 0;
  Future<List<Map<String, dynamic>>> getCategoryStats() async => [];
  Future<void> close() async {}
  Future<void> resetDatabase() async {}

  // ============================================================
  // DEFAULT DATA FOR WEB PREVIEW
  // ============================================================

  List<Category> _getDefaultCategories() {
    return [
      Category(id: 1, name: 'Makan', type: Category.typeExpense),
      Category(id: 2, name: 'Transport', type: Category.typeExpense),
      Category(id: 3, name: 'Gaji', type: Category.typeIncome),
      Category(id: 4, name: 'Bonus', type: Category.typeIncome),
      Category(id: 5, name: 'Freelance', type: Category.typeIncome),
      Category(id: 6, name: 'Belanja', type: Category.typeExpense),
      Category(id: 7, name: 'Hiburan', type: Category.typeExpense),
      Category(id: 8, name: 'Tagihan', type: Category.typeExpense),
      Category(id: 9, name: 'Kesehatan', type: Category.typeExpense),
      Category(id: 10, name: 'Lainnya', type: Category.typeExpense),
    ];
  }
}
