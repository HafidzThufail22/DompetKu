import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
// Conditional import: gunakan database_helper untuk mobile, stub untuk web
import '../db/database_helper_stub.dart'
    if (dart.library.io) '../db/database_helper.dart';

/// Provider/ViewModel untuk mengelola state transaksi dan kategori
/// Menghubungkan Database dengan UI menggunakan ChangeNotifier
class TransactionProvider extends ChangeNotifier {
  // ============================================================
  // PRIVATE VARIABLES
  // ============================================================

  /// Instance DatabaseHelper (Singleton) - null di web
  final dynamic _dbHelper = kIsWeb ? null : DatabaseHelper();

  /// SharedPreferences instance
  SharedPreferences? _prefs;

  /// List semua transaksi dari database
  List<Transaction> _allTransactions = [];

  /// List kategori yang disimpan di memory
  List<Category> _categories = [];

  /// Loading state untuk UI
  bool _isLoading = false;

  /// Bulan yang dipilih untuk filter (default: bulan ini)
  DateTime _selectedMonth = DateTime.now();

  /// Counter untuk generate ID di mode web
  int _webTransactionIdCounter = 0;
  int _webCategoryIdCounter = 10;

  // ============================================================
  // HIDE BALANCE FEATURE
  // ============================================================

  /// Status hide/show balance (persisten via SharedPreferences)
  bool _isBalanceHidden = false;

  /// Key untuk SharedPreferences
  static const String _keyHideBalance = 'hide_balance';
  static const String _keySelectedWalletId = 'selected_wallet_id';

  /// Getter untuk status hide balance
  bool get isBalanceHidden => _isBalanceHidden;

  /// Toggle visibility balance dan simpan ke SharedPreferences
  Future<void> toggleBalanceVisibility() async {
    _isBalanceHidden = !_isBalanceHidden;
    notifyListeners();

    // Simpan ke SharedPreferences
    await _savePreference(_keyHideBalance, _isBalanceHidden);
  }

  /// Set visibility balance secara langsung
  Future<void> setBalanceVisibility(bool hidden) async {
    _isBalanceHidden = hidden;
    notifyListeners();
    await _savePreference(_keyHideBalance, hidden);
  }

  // ============================================================
  // MULTI-WALLET FEATURE
  // ============================================================

  /// ID wallet yang dipilih (null = All Wallets)
  int? _selectedWalletId;

  /// Getter untuk wallet yang dipilih
  int? get selectedWalletId => _selectedWalletId;

  /// Cek apakah menampilkan semua wallet
  bool get isAllWallets => _selectedWalletId == null;

  /// Pilih wallet dan refresh transaksi
  Future<void> selectWallet(int? walletId) async {
    _selectedWalletId = walletId;
    notifyListeners();

    // Simpan ke SharedPreferences
    if (walletId != null) {
      await _savePreference(_keySelectedWalletId, walletId);
    } else {
      await _removePreference(_keySelectedWalletId);
    }

    // Reload transaksi berdasarkan wallet baru
    await loadTransactions();
  }

  /// Filter transaksi berdasarkan wallet
  List<Transaction> _filterByWallet(List<Transaction> txns) {
    if (_selectedWalletId == null) return txns;
    return txns.where((t) => t.walletId == _selectedWalletId).toList();
  }

  // ============================================================
  // PREFERENCES MANAGEMENT
  // ============================================================

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load semua preferences dari SharedPreferences
  Future<void> loadPreferences() async {
    try {
      await _initPrefs();

      // Load hide balance status
      _isBalanceHidden = _prefs?.getBool(_keyHideBalance) ?? false;

      // Load selected wallet ID
      final walletId = _prefs?.getInt(_keySelectedWalletId);
      _selectedWalletId = walletId;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  /// Save preference ke SharedPreferences
  Future<void> _savePreference(String key, dynamic value) async {
    try {
      await _initPrefs();
      if (value is bool) {
        await _prefs?.setBool(key, value);
      } else if (value is int) {
        await _prefs?.setInt(key, value);
      } else if (value is String) {
        await _prefs?.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  /// Remove preference dari SharedPreferences
  Future<void> _removePreference(String key) async {
    try {
      await _initPrefs();
      await _prefs?.remove(key);
    } catch (e) {
      debugPrint('Error removing preference: $e');
    }
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Constructor - auto initialize
  TransactionProvider() {
    _init();
  }

  /// Initialize provider (load preferences dan data)
  Future<void> _init() async {
    await loadPreferences();
    await loadCategories();
    await loadTransactions();
  }

  // ============================================================
  // GETTERS - Basic
  // ============================================================

  /// Getter untuk bulan yang dipilih
  DateTime get selectedMonth => _selectedMonth;

  /// Getter untuk transaksi yang sudah difilter berdasarkan bulan DAN wallet
  List<Transaction> get transactions {
    var filtered = _allTransactions.where((t) {
      try {
        final date = DateTime.parse(t.date);
        return date.year == _selectedMonth.year && 
               date.month == _selectedMonth.month;
      } catch (e) {
        return false;
      }
    }).toList();

    // Filter by wallet jika ada
    return _filterByWallet(filtered);
  }

  /// Getter untuk semua transaksi (filtered by wallet)
  List<Transaction> get allTransactions => _filterByWallet(_allTransactions);

  /// Getter untuk mengakses list kategori (read-only)
  List<Category> get categories => _categories;

  /// Getter untuk kategori income saja
  List<Category> get incomeCategories => 
      _categories.where((c) => c.type == Category.typeIncome).toList();

  /// Getter untuk kategori expense saja
  List<Category> get expenseCategories => 
      _categories.where((c) => c.type == Category.typeExpense).toList();

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  // ============================================================
  // GETTERS - Balance (Filtered by Wallet)
  // ============================================================

  /// Getter untuk menghitung total saldo (filtered by wallet)
  int get totalBalance {
    final txns = _filterByWallet(_allTransactions);
    int income = 0;
    int expense = 0;

    for (var transaction in txns) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return income - expense;
  }

  /// Getter untuk total pemasukan (filtered by wallet)
  int get totalIncome {
    return _filterByWallet(_allTransactions)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Getter untuk total pengeluaran (filtered by wallet)
  int get totalExpense {
    return _filterByWallet(_allTransactions)
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Getter untuk jumlah transaksi (yang sudah difilter)
  int get transactionCount => transactions.length;

  // ============================================================
  // MONTHLY SUMMARY - REKAP BULANAN (Filtered by Wallet)
  // ============================================================

  /// Getter untuk rekap bulanan (bulan yang dipilih)
  Map<String, int> get monthlySummary {
    final filteredTransactions = transactions;
    
    int income = 0;
    int expense = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  /// Getter untuk pemasukan bulan ini
  int get monthlyIncome => monthlySummary['income'] ?? 0;

  /// Getter untuk pengeluaran bulan ini
  int get monthlyExpense => monthlySummary['expense'] ?? 0;

  /// Getter untuk saldo bulan ini
  int get monthlyBalance => monthlySummary['balance'] ?? 0;

  /// Getter untuk nama bulan yang dipilih (format: "Januari 2026")
  String get selectedMonthName {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  // ============================================================
  // REPORT HELPERS - Data untuk PieChart
  // ============================================================

  /// Mendapatkan pengeluaran per kategori (untuk PieChart)
  List<Map<String, dynamic>> getExpensesByCategory() {
    final filteredTransactions = transactions.where((t) => t.isExpense);
    return _groupByCategory(filteredTransactions);
  }

  /// Mendapatkan pemasukan per kategori (untuk PieChart)
  List<Map<String, dynamic>> getIncomeByCategory() {
    final filteredTransactions = transactions.where((t) => t.isIncome);
    return _groupByCategory(filteredTransactions);
  }

  /// Helper untuk mengelompokkan transaksi per kategori
  List<Map<String, dynamic>> _groupByCategory(Iterable<Transaction> txns) {
    final Map<int, Map<String, dynamic>> grouped = {};

    for (var transaction in txns) {
      final categoryId = transaction.categoryId;
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = {
          'category': transaction.category ?? getCategoryById(categoryId),
          'total': 0,
          'count': 0,
        };
      }
      grouped[categoryId]!['total'] += transaction.amount;
      grouped[categoryId]!['count'] += 1;
    }

    final result = grouped.values.toList();
    result.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    return result;
  }

  // ============================================================
  // MONTH FILTER FUNCTIONS
  // ============================================================

  /// Mengubah bulan yang dipilih dan refresh tampilan
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  /// Pindah ke bulan sebelumnya
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
  }

  /// Pindah ke bulan berikutnya
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
  }

  /// Reset ke bulan ini
  void resetToCurrentMonth() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    notifyListeners();
  }

  /// Cek apakah bulan yang dipilih adalah bulan ini
  bool get isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  // ============================================================
  // CATEGORY CRUD FUNCTIONS
  // ============================================================

  /// Memuat semua kategori dari database
  Future<void> loadCategories() async {
    try {
      if (kIsWeb) {
        if (_categories.isEmpty) {
          _categories = _getDefaultCategories();
        }
      } else {
        _categories = await _dbHelper.getCategoryList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = _getDefaultCategories();
      notifyListeners();
    }
  }

  /// Mendapatkan kategori berdasarkan ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mendapatkan kategori berdasarkan tipe
  List<Category> getCategoriesByType(int type) {
    return _categories.where((c) => c.type == type).toList();
  }

  /// Menambahkan kategori baru
  Future<bool> addCategory(Category category) async {
    try {
      if (kIsWeb) {
        _webCategoryIdCounter++;
        final newCategory = Category(
          id: _webCategoryIdCounter,
          name: category.name,
          type: category.type,
        );
        _categories.add(newCategory);
        notifyListeners();
      } else {
        await _dbHelper.insertCategory(category);
        await loadCategories();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  /// Mengupdate kategori
  Future<bool> updateCategory(Category category) async {
    try {
      if (kIsWeb) {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
          notifyListeners();
        }
      } else {
        await _dbHelper.updateCategory(category);
        await loadCategories();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  /// Menghapus kategori
  Future<bool> deleteCategory(int id) async {
    try {
      final hasTransactions = _allTransactions.any((t) => t.categoryId == id);
      if (hasTransactions) {
        debugPrint('Cannot delete category: has transactions');
        return false;
      }

      if (kIsWeb) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
      } else {
        await _dbHelper.deleteCategory(id);
        await loadCategories();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  /// Cek apakah kategori bisa dihapus
  bool canDeleteCategory(int categoryId) {
    return !_allTransactions.any((t) => t.categoryId == categoryId);
  }

  /// Hitung jumlah transaksi per kategori
  int getTransactionCountByCategory(int categoryId) {
    return _allTransactions.where((t) => t.categoryId == categoryId).length;
  }

  // ============================================================
  // TRANSACTION CRUD FUNCTIONS
  // ============================================================

  /// Memuat semua transaksi dari database
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_categories.isEmpty) {
        await loadCategories();
      }

      if (kIsWeb) {
        if (_allTransactions.isEmpty) {
          _allTransactions = _getSampleTransactions();
        }
      } else {
        _allTransactions = await _dbHelper.getTransactionList();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _allTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan transaksi baru
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      if (kIsWeb) {
        _webTransactionIdCounter++;
        final category = getCategoryById(transaction.categoryId);
        final newTransaction = Transaction(
          id: _webTransactionIdCounter,
          title: transaction.title,
          amount: transaction.amount,
          categoryId: transaction.categoryId,
          date: transaction.date,
          category: category,
          walletId: transaction.walletId ?? _selectedWalletId,
        );
        _allTransactions.insert(0, newTransaction);
        _allTransactions.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      } else {
        await _dbHelper.insertTransaction(transaction);
        await loadTransactions();
      }

      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  /// Mengupdate transaksi
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      if (kIsWeb) {
        final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          final category = getCategoryById(transaction.categoryId);
          _allTransactions[index] = transaction.copyWith(category: category);
          notifyListeners();
        }
      } else {
        await _dbHelper.updateTransaction(transaction);
        await loadTransactions();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  /// Menghapus transaksi berdasarkan ID
  Future<bool> deleteTransaction(int id) async {
    try {
      if (kIsWeb) {
        _allTransactions.removeWhere((t) => t.id == id);
        notifyListeners();
      } else {
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

  List<Transaction> _getSampleTransactions() {
    _webTransactionIdCounter = 10;
    final now = DateTime.now();
    
    return [
      Transaction(
        id: 1,
        title: 'Gaji Bulanan',
        amount: 5000000,
        categoryId: 3,
        date: DateTime(now.year, now.month, 1, 9, 0).toIso8601String(),
        category: Category(id: 3, name: 'Gaji', type: Category.typeIncome),
      ),
      Transaction(
        id: 2,
        title: 'Makan Siang',
        amount: 50000,
        categoryId: 1,
        date: DateTime(now.year, now.month, 5, 12, 30).toIso8601String(),
        category: Category(id: 1, name: 'Makan', type: Category.typeExpense),
      ),
      Transaction(
        id: 3,
        title: 'Freelance Project',
        amount: 2000000,
        categoryId: 5,
        date: DateTime(now.year, now.month, 10, 15, 0).toIso8601String(),
        category: Category(id: 5, name: 'Freelance', type: Category.typeIncome),
      ),
      Transaction(
        id: 4,
        title: 'Ojek Online',
        amount: 25000,
        categoryId: 2,
        date: DateTime(now.year, now.month, 12, 8, 15).toIso8601String(),
        category: Category(id: 2, name: 'Transport', type: Category.typeExpense),
      ),
      Transaction(
        id: 5,
        title: 'Bayar Listrik',
        amount: 350000,
        categoryId: 8,
        date: DateTime(now.year, now.month, 15, 10, 0).toIso8601String(),
        category: Category(id: 8, name: 'Tagihan', type: Category.typeExpense),
      ),
      Transaction(
        id: 6,
        title: 'Gaji Bulan Lalu',
        amount: 5000000,
        categoryId: 3,
        date: DateTime(now.year, now.month - 1, 1, 9, 0).toIso8601String(),
        category: Category(id: 3, name: 'Gaji', type: Category.typeIncome),
      ),
      Transaction(
        id: 7,
        title: 'Belanja Bulanan',
        amount: 1500000,
        categoryId: 6,
        date: DateTime(now.year, now.month - 1, 20, 14, 0).toIso8601String(),
        category: Category(id: 6, name: 'Belanja', type: Category.typeExpense),
      ),
    ];
  }

  // ============================================================
  // UTILITY FUNCTIONS
  // ============================================================

  /// Mendapatkan transaksi berdasarkan kategori
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Mendapatkan transaksi berdasarkan tipe
  List<Transaction> getTransactionsByType(int type) {
    return transactions.where((t) => t.type == type).toList();
  }

  /// Mendapatkan transaksi berdasarkan tanggal tertentu
  List<Transaction> getTransactionsByDate(DateTime date) {
    return _filterByWallet(_allTransactions).where((t) {
      try {
        final tDate = DateTime.parse(t.date);
        return tDate.year == date.year && 
               tDate.month == date.month && 
               tDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Mendapatkan rekap per kategori untuk bulan yang dipilih
  List<Map<String, dynamic>> getCategoryBreakdown() {
    final filteredTransactions = transactions;
    final Map<int, Map<String, dynamic>> breakdown = {};

    for (var transaction in filteredTransactions) {
      final categoryId = transaction.categoryId;
      if (!breakdown.containsKey(categoryId)) {
        breakdown[categoryId] = {
          'category': transaction.category,
          'total': 0,
          'count': 0,
        };
      }
      breakdown[categoryId]!['total'] += transaction.amount;
      breakdown[categoryId]!['count'] += 1;
    }

    return breakdown.values.toList()
      ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
  }

  /// Clear semua data (untuk keperluan testing/reset)
  void clearTransactions() {
    _allTransactions = [];
    notifyListeners();
  }

  /// Reload semua data
  Future<void> refreshAll() async {
    await loadCategories();
    await loadTransactions();
  }

  /// Format balance untuk display (dengan hide option)
  String getDisplayBalance(int amount, {bool forceShow = false}) {
    if (_isBalanceHidden && !forceShow) {
      return '••••••••';
    }
    return amount.toString();
  }
}
