import 'category_model.dart';

/// Model class untuk transaksi keuangan
/// Merepresentasikan satu baris data di tabel 'transactions'
/// Dengan relasi ke tabel 'categories' dan 'wallets'
class Transaction {
  /// ID unik transaksi (auto-generated oleh database)
  final int? id;

  /// Judul/deskripsi transaksi (contoh: "Gaji Bulanan", "Beli Makan")
  final String title;

  /// Nominal transaksi dalam Rupiah
  final int amount;

  /// ID kategori (Foreign Key ke tabel categories)
  final int categoryId;

  /// Tanggal dan waktu transaksi dalam format ISO 8601 lengkap
  /// Contoh: "2026-01-31T14:30:00"
  final String date;

  /// Objek Category (untuk hasil JOIN query)
  /// Nullable karena tidak selalu di-load
  final Category? category;

  /// ID wallet (untuk fitur Multi-Wallet)
  /// Nullable, jika null akan menggunakan wallet default
  final int? walletId;

  /// Constructor
  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.category,
    this.walletId,
  });

  /// Konstanta untuk backward compatibility
  /// Gunakan Category.typeIncome dan Category.typeExpense untuk kode baru
  static const int typeIncome = 1;
  static const int typeExpense = 0;

  /// Mengkonversi object Transaction ke Map untuk disimpan ke database
  /// Tidak menyertakan 'category' karena itu hasil JOIN
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date,
      'wallet_id': walletId,
    };
  }

  /// Factory constructor untuk membuat object Transaction dari Map
  /// Untuk query sederhana tanpa JOIN
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      categoryId: map['category_id'] as int,
      date: map['date'] as String,
      // wallet_id mungkin tidak ada di database lama
      walletId: map.containsKey('wallet_id') ? map['wallet_id'] as int? : null,
    );
  }

  /// Factory constructor untuk membuat object Transaction dari Map dengan JOIN
  /// Menyertakan data kategori
  factory Transaction.fromMapWithCategory(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      categoryId: map['category_id'] as int,
      date: map['date'] as String,
      // wallet_id mungkin tidak ada di database lama
      walletId: map.containsKey('wallet_id') ? map['wallet_id'] as int? : null,
      category: Category(
        id: map['category_id'] as int?,
        name: map['category_name'] as String? ?? 'Unknown',
        type: map['category_type'] as int? ?? 0,
      ),
    );
  }

  /// Helper getter untuk mengecek apakah transaksi adalah pemasukan
  /// Menggunakan data kategori jika tersedia
  bool get isIncome => category?.isIncome ?? false;

  /// Helper getter untuk mengecek apakah transaksi adalah pengeluaran
  bool get isExpense => category?.isExpense ?? true;

  /// Helper getter untuk mendapatkan tipe dari kategori
  int get type => category?.type ?? Category.typeExpense;

  /// Helper getter untuk mendapatkan nama kategori
  String get categoryName => category?.name ?? 'Unknown';

  /// Override toString untuk debugging
  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, categoryId: $categoryId, category: ${category?.name}, date: $date, walletId: $walletId)';
  }

  /// Copy with method untuk membuat salinan dengan perubahan
  Transaction copyWith({
    int? id,
    String? title,
    int? amount,
    int? categoryId,
    String? date,
    Category? category,
    int? walletId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
    );
  }
}
