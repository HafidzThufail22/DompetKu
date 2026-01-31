/// Model class untuk transaksi keuangan
/// Merepresentasikan satu baris data di tabel 'transactions'
class Transaction {
  /// ID unik transaksi (auto-generated oleh database)
  final int? id;

  /// Judul/deskripsi transaksi (contoh: "Gaji Bulanan", "Beli Makan")
  final String title;

  /// Nominal transaksi dalam Rupiah
  final int amount;

  /// Tipe transaksi: 1 = Pemasukan, 0 = Pengeluaran
  final int type;

  /// Tanggal transaksi dalam format String (ISO 8601: "2026-01-31")
  final String date;

  /// Constructor
  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  /// Konstanta untuk tipe transaksi (best practice untuk menghindari magic numbers)
  static const int typeIncome = 1;     // Pemasukan
  static const int typeExpense = 0;    // Pengeluaran

  /// Mengkonversi object Transaction ke Map untuk disimpan ke database
  /// Digunakan saat INSERT atau UPDATE ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date,
    };
  }

  /// Factory constructor untuk membuat object Transaction dari Map
  /// Digunakan saat membaca data dari SQLite
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as int,
      type: map['type'] as int,
      date: map['date'] as String,
    );
  }

  /// Helper getter untuk mengecek apakah transaksi adalah pemasukan
  bool get isIncome => type == typeIncome;

  /// Helper getter untuk mengecek apakah transaksi adalah pengeluaran
  bool get isExpense => type == typeExpense;

  /// Override toString untuk debugging
  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, type: ${isIncome ? "Pemasukan" : "Pengeluaran"}, date: $date)';
  }
}
