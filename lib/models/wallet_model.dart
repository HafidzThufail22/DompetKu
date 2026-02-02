/// Model class untuk Wallet (Dompet)
/// Merepresentasikan satu baris data di tabel 'wallets'
import 'package:flutter/material.dart';

class Wallet {
  /// ID unik wallet (auto-generated oleh database)
  final int? id;

  /// Nama wallet (contoh: "Tunai", "Bank BCA", "GoPay")
  final String name;

  /// Nama icon dari Icons class (contoh: "money", "account_balance")
  final String icon;

  /// Warna wallet dalam format hex string (contoh: "0xFF4CAF50")
  final String? color;

  /// Constructor
  Wallet({
    this.id,
    required this.name,
    required this.icon,
    this.color,
  });

  /// Daftar icon yang tersedia untuk dipilih
  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'money', 'icon': Icons.money, 'label': 'Uang'},
    {'name': 'account_balance', 'icon': Icons.account_balance, 'label': 'Bank'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'E-Wallet'},
    {'name': 'credit_card', 'icon': Icons.credit_card, 'label': 'Kartu'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Tabungan'},
    {'name': 'wallet', 'icon': Icons.wallet, 'label': 'Dompet'},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet, 'label': 'Wallet'},
    {'name': 'attach_money', 'icon': Icons.attach_money, 'label': 'Dollar'},
    {'name': 'currency_exchange', 'icon': Icons.currency_exchange, 'label': 'Exchange'},
    {'name': 'payments', 'icon': Icons.payments, 'label': 'Pembayaran'},
    {'name': 'local_atm', 'icon': Icons.local_atm, 'label': 'ATM'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Belanja'},
  ];

  /// Mendapatkan IconData berdasarkan nama icon
  static IconData getIconData(String iconName) {
    final iconMap = {
      'money': Icons.money,
      'account_balance': Icons.account_balance,
      'phone_android': Icons.phone_android,
      'credit_card': Icons.credit_card,
      'savings': Icons.savings,
      'wallet': Icons.wallet,
      'account_balance_wallet': Icons.account_balance_wallet,
      'attach_money': Icons.attach_money,
      'currency_exchange': Icons.currency_exchange,
      'payments': Icons.payments,
      'local_atm': Icons.local_atm,
      'shopping_bag': Icons.shopping_bag,
    };
    return iconMap[iconName] ?? Icons.account_balance_wallet;
  }

  /// Getter untuk mendapatkan IconData
  IconData get iconData => getIconData(icon);

  /// Mengkonversi object Wallet ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  /// Factory constructor untuk membuat object Wallet dari Map
  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? 'account_balance_wallet',
      color: map['color'] as String?,
    );
  }

  /// Copy with method untuk membuat salinan dengan perubahan
  Wallet copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Wallet(id: $id, name: $name, icon: $icon, color: $color)';
  }

  /// Default wallets
  static List<Wallet> get defaultWallets => [
    Wallet(id: 1, name: 'Tunai', icon: 'money'),
    Wallet(id: 2, name: 'Bank', icon: 'account_balance'),
    Wallet(id: 3, name: 'E-Wallet', icon: 'phone_android'),
  ];
}
