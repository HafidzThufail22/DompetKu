import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
// Conditional import: gunakan database_helper untuk mobile, dummy untuk web
import '../db/database_helper_stub.dart'
    if (dart.library.io) '../db/database_helper.dart';

/// Provider/ViewModel untuk mengelola state transaksi
/// Menghubungkan Database dengan UI menggunakan ChangeNotifier
class TransactionProvider extends ChangeNotifier {
  // ============================================================
  // PRIVATE VARIABLES
  // ============================================================

  /// Instance DatabaseHelper (Singleton) - null di web
  final dynamic _dbHelper = kIsWeb ? null : DatabaseHelper();

  /// List transaksi yang disimpan di memory
  List<Transaction> _transactions = [];

  /// Loading state untuk UI
  bool _isLoading = false;

  /// Counter untuk generate ID di mode web
  int _webIdCounter = 0;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Getter untuk mengakses list transaksi (read-only)
  List<Transaction> get transactions => _transactions;

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  /// Getter untuk menghitung total saldo
  /// Rumus: Total Pemasukan - Total Pengeluaran
  int get totalBalance {
    int income = 0;
    int expense = 0;

    for (var transaction in _transactions) {
      if (transaction.type == Transaction.typeIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return income - expense;
  }

  /// Getter untuk total pemasukan saja
  int get totalIncome {
    return _transactions
        .where((t) => t.type == Transaction.typeIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Getter untuk total pengeluaran saja
  int get totalExpense {
    return _transactions
        .where((t) => t.type == Transaction.typeExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Getter untuk jumlah transaksi
  int get transactionCount => _transactions.length;

  // ============================================================
  // CRUD FUNCTIONS
  // ============================================================

  /// Memuat semua transaksi dari database
  /// Dipanggil pertama kali saat aplikasi dibuka
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Mode Web: Load sample data untuk preview
        if (_transactions.isEmpty) {
          _transactions = _getSampleTransactions();
        }
      } else {
        // Mode Mobile: Ambil data dari database
        _transactions = await _dbHelper.getTransactionList();
      }
    } catch (e) {
      // Handle error (bisa ditambahkan logging)
      debugPrint('Error loading transactions: $e');
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan transaksi baru
  /// Setelah insert ke database, refresh list untuk update UI
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      if (kIsWeb) {
        // Mode Web: Simpan di memory saja
        _webIdCounter++;
        final newTransaction = Transaction(
          id: _webIdCounter,
          title: transaction.title,
          amount: transaction.amount,
          type: transaction.type,
          date: transaction.date,
        );
        _transactions.insert(0, newTransaction);
        notifyListeners();
      } else {
        // Mode Mobile: Insert ke database
        await _dbHelper.insertTransaction(transaction);
        await loadTransactions();
      }

      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  /// Menghapus transaksi berdasarkan ID
  /// Setelah delete dari database, refresh list untuk update UI
  Future<bool> deleteTransaction(int id) async {
    try {
      if (kIsWeb) {
        // Mode Web: Hapus dari memory
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();
      } else {
        // Mode Mobile: Hapus dari database
        await _dbHelper.deleteTransaction(id);
        await loadTransactions();
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  // ============================================================
  // SAMPLE DATA (untuk preview di Web)
  // ============================================================

  List<Transaction> _getSampleTransactions() {
    _webIdCounter = 5;
    return [
      Transaction(
        id: 1,
        title: 'Gaji Bulanan',
        amount: 5000000,
        type: Transaction.typeIncome,
        date: '2026-01-31',
      ),
      Transaction(
        id: 2,
        title: 'Belanja Bulanan',
        amount: 1500000,
        type: Transaction.typeExpense,
        date: '2026-01-30',
      ),
      Transaction(
        id: 3,
        title: 'Freelance Project',
        amount: 2000000,
        type: Transaction.typeIncome,
        date: '2026-01-28',
      ),
      Transaction(
        id: 4,
        title: 'Bayar Listrik',
        amount: 350000,
        type: Transaction.typeExpense,
        date: '2026-01-25',
      ),
      Transaction(
        id: 5,
        title: 'Makan Siang',
        amount: 50000,
        type: Transaction.typeExpense,
        date: '2026-01-25',
      ),
    ];
  }

  // ============================================================
  // UTILITY FUNCTIONS
  // ============================================================

  /// Mendapatkan transaksi berdasarkan tipe
  /// [type]: Transaction.typeIncome atau Transaction.typeExpense
  List<Transaction> getTransactionsByType(int type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Mendapatkan transaksi berdasarkan tanggal
  List<Transaction> getTransactionsByDate(String date) {
    return _transactions.where((t) => t.date == date).toList();
  }

  /// Clear semua data (untuk keperluan testing/reset)
  void clearTransactions() {
    _transactions = [];
    notifyListeners();
  }
}
