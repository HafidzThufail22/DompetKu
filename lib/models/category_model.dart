/// Model class untuk kategori transaksi
/// Merepresentasikan satu baris data di tabel 'categories'
class Category {
  /// ID unik kategori (auto-generated oleh database)
  final int? id;

  /// Nama kategori (contoh: "Makan", "Gaji", "Transport")
  final String name;

  /// Tipe kategori: 1 = Income, 0 = Expense
  final int type;

  /// Constructor
  Category({
    this.id,
    required this.name,
    required this.type,
  });

  /// Konstanta untuk tipe kategori
  static const int typeIncome = 1;   // Pemasukan
  static const int typeExpense = 0;  // Pengeluaran

  /// Mengkonversi object Category ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  /// Factory constructor untuk membuat object Category dari Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as int,
    );
  }

  /// Helper getter untuk mengecek apakah kategori adalah income
  bool get isIncome => type == typeIncome;

  /// Helper getter untuk mengecek apakah kategori adalah expense
  bool get isExpense => type == typeExpense;

  /// Override toString untuk debugging
  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: ${isIncome ? "Income" : "Expense"})';
  }

  /// Copy with method untuk membuat salinan dengan perubahan
  Category copyWith({
    int? id,
    String? name,
    int? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }
}
