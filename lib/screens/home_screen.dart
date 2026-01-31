import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    // Load transaksi saat pertama kali screen dibuka
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  // ============================================================
  // HELPER FUNCTIONS
  // ============================================================

  /// Format angka ke format Rupiah (IDR)
  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format tanggal untuk tampilan
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DompetKu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionProvider>().loadTransactions();
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // ============================================
              // BALANCE CARD
              // ============================================
              _buildBalanceCard(provider),

              // ============================================
              // INCOME & EXPENSE SUMMARY
              // ============================================
              _buildSummaryRow(provider),

              // ============================================
              // TRANSACTION LIST HEADER
              // ============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${provider.transactionCount} transaksi',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // TRANSACTION LIST
              // ============================================
              Expanded(
                child: provider.transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList(provider),
              ),
            ],
          );
        },
      ),

      // ============================================
      // FLOATING ACTION BUTTON
      // ============================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDERS
  // ============================================================

  /// Kartu saldo total di bagian atas
  Widget _buildBalanceCard(TransactionProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Saldo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(provider.totalBalance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Baris ringkasan pemasukan dan pengeluaran
  Widget _buildSummaryRow(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Pemasukan
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.incomeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.income,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          formatRupiah(provider.totalIncome),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.income,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Pengeluaran
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.expenseLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          formatRupiah(provider.totalExpense),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.expense,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan saat list kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah transaksi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// List transaksi
  Widget _buildTransactionList(TransactionProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return _buildTransactionItem(transaction, provider);
      },
    );
  }

  /// Item transaksi individual
  Widget _buildTransactionItem(Transaction transaction, TransactionProvider provider) {
    final isIncome = transaction.isIncome;

    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Transaksi'),
            content: const Text('Yakin ingin menghapus transaksi ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteTransaction(transaction.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODAL BOTTOM SHEET - ADD TRANSACTION
  // ============================================================

  void _showAddTransactionModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    int selectedType = Transaction.typeIncome; // Default: Pemasukan

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Transaksi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tipe Transaksi (Toggle)
                    const Text(
                      'Tipe Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedType = Transaction.typeIncome;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == Transaction.typeIncome
                                    ? AppColors.income
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: selectedType == Transaction.typeIncome
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == Transaction.typeIncome
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedType = Transaction.typeExpense;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == Transaction.typeExpense
                                    ? AppColors.expense
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: selectedType == Transaction.typeExpense
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == Transaction.typeExpense
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Judul Transaksi
                    const Text(
                      'Judul',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Gaji Bulanan',
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Nominal
                    const Text(
                      'Nominal (Rp)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 500000',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Nominal harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            // Buat object transaksi baru
                            final transaction = Transaction(
                              title: titleController.text.trim(),
                              amount: int.parse(amountController.text),
                              type: selectedType,
                              date: DateTime.now().toIso8601String().split('T')[0],
                            );

                            // Simpan ke database via provider
                            final success = await context
                                .read<TransactionProvider>()
                                .addTransaction(transaction);

                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Transaksi "${transaction.title}" berhasil ditambahkan!',
                                  ),
                                  backgroundColor: AppColors.income,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
