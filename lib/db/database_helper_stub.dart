// Stub database helper untuk platform Web
// File ini digunakan saat aplikasi berjalan di web browser

import '../models/transaction_model.dart';

/// Stub DatabaseHelper untuk Web
/// Semua method mengembalikan nilai kosong karena tidak ada database di web
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Table name (untuk konsistensi dengan versi mobile)
  static const String tableName = 'transactions';

  // Stub methods - tidak melakukan apa-apa di web
  Future<int> insertTransaction(Transaction transaction) async => 0;
  Future<List<Transaction>> getTransactionList() async => [];
  Future<int> deleteTransaction(int id) async => 0;
  Future<int> getTotalBalance() async => 0;
  Future<void> close() async {}
}
