import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
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
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  // ============================================================
  // HELPER FUNCTIONS
  // ============================================================

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM, HH:mm', 'id_ID').format(date);
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
              context.read<TransactionProvider>().refreshAll();
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ============================================
              // WALLET FILTER (Fixed at top)
              // ============================================
              _buildWalletFilter(provider),

              // ============================================
              // SCROLLABLE CONTENT
              // ============================================
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ============================================
                      // MONTH FILTER
                      // ============================================
                      _buildMonthFilter(provider),

                      // ============================================
                      // BALANCE CARD (Monthly)
                      // ============================================
                      _buildBalanceCard(provider),

                      // ============================================
                      // INCOME & EXPENSE SUMMARY (Monthly)
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
                      // TRANSACTION LIST (Inline, not Expanded)
                      // ============================================
                      if (provider.transactions.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: provider.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = provider.transactions[index];
                            return _buildTransactionItem(transaction, provider);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  // ============================================================
  // WALLET FILTER WIDGET
  // ============================================================

  /// Sample wallet data (nanti bisa dari database)
  final List<Map<String, dynamic>> _wallets = [
    {'id': null, 'name': 'Semua', 'icon': Icons.account_balance_wallet},
    {'id': 1, 'name': 'Tunai', 'icon': Icons.money},
    {'id': 2, 'name': 'Bank', 'icon': Icons.account_balance},
    {'id': 3, 'name': 'E-Wallet', 'icon': Icons.phone_android},
  ];

  Widget _buildWalletFilter(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Wallet Chips
            ..._wallets.map((wallet) {
              final isSelected = provider.selectedWalletId == wallet['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.selectWallet(wallet['id'] as int?),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          wallet['icon'] as IconData,
                          size: 18,
                          color: isSelected 
                              ? const Color(0xFF0D0D0D)
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          wallet['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? const Color(0xFF0D0D0D)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Add Wallet Button
            GestureDetector(
              onTap: () => _showAddWalletDialog(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tambah Dompet Baru'),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nama dompet',
            filled: true,
            fillColor: AppColors.surfaceLight,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // TODO: Implement add wallet to database
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dompet "${nameController.text}" akan ditambahkan'),
                    backgroundColor: AppColors.income,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0D0D0D),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH FILTER WIDGET
  // ============================================================

  Widget _buildMonthFilter(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month Button
          IconButton(
            onPressed: () => provider.previousMonth(),
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Month Display
          GestureDetector(
            onTap: () => _showMonthPicker(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: provider.isCurrentMonth 
                    ? AppColors.primary.withAlpha(30)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: provider.isCurrentMonth 
                      ? AppColors.primary 
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: provider.isCurrentMonth 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.selectedMonthName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: provider.isCurrentMonth 
                          ? AppColors.primary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Month Button
          IconButton(
            onPressed: () => provider.nextMonth(),
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final now = DateTime.now();
        final months = List.generate(12, (index) {
          return DateTime(now.year, now.month - index, 1);
        });

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Bulan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: months.map((month) {
                  final isSelected = month.year == provider.selectedMonth.year &&
                      month.month == provider.selectedMonth.month;
                  final monthName = DateFormat('MMM yyyy', 'id_ID').format(month);

                  return GestureDetector(
                    onTap: () {
                      provider.setSelectedMonth(month);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        monthName,
                        style: TextStyle(
                          color: isSelected 
                              ? const Color(0xFF0D0D0D) 
                              : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (!provider.isCurrentMonth)
                TextButton.icon(
                  onPressed: () {
                    provider.resetToCurrentMonth();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.today, color: AppColors.primary),
                  label: const Text(
                    'Kembali ke Bulan Ini',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BALANCE CARD - Shows Monthly Summary
  // ============================================================

  /// Format balance dengan opsi hidden
  String _formatBalanceDisplay(int amount, bool isHidden) {
    if (isHidden) {
      return 'Rp ••••••••';
    }
    return formatRupiah(amount);
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    final isHidden = provider.isBalanceHidden;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC6FF00), Color(0xFFADE000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Keuangan Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D0D0D),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(77),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.selectedMonthName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Hide/Show Balance Toggle
                  GestureDetector(
                    onTap: () => provider.toggleBalanceVisibility(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(77),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Saldo Bulan Ini',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 8),
              if (isHidden)
                const Icon(
                  Icons.lock,
                  size: 14,
                  color: Color(0xFF666666),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatBalanceDisplay(provider.monthlyBalance, isHidden),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D0D0D),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total: ${_formatBalanceDisplay(provider.totalBalance, isHidden)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW - Monthly Income & Expense
  // ============================================================

  Widget _buildSummaryRow(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Income Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.incomeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.income,
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
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(provider.monthlyIncome),
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
          // Expense Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.expenseLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.expense,
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
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(provider.monthlyExpense),
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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk menambah transaksi',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION LIST
  // ============================================================

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
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Hapus Transaksi'),
            content: const Text('Yakin ingin menghapus transaksi ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteTransaction(transaction.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi dihapus')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title, Category & Date
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isIncome ? AppColors.income : AppColors.expense,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(transaction.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${isIncome ? '+' : '-'}${formatRupiah(transaction.amount)}',
              style: TextStyle(
                fontSize: 15,
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
  // ADD TRANSACTION MODAL
  // ============================================================

  void _showAddTransactionModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    int selectedType = Category.typeIncome;
    Category? selectedCategory;
    DateTime selectedDateTime = DateTime.now();

    final provider = context.read<TransactionProvider>();
    if (provider.categories.isEmpty) {
      provider.loadCategories();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = selectedType == Category.typeIncome
              ? provider.incomeCategories
              : provider.expenseCategories;

          if (selectedCategory == null || selectedCategory!.type != selectedType) {
            selectedCategory = categories.isNotEmpty ? categories.first : null;
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
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
                      const SizedBox(height: 20),

                      // Type Toggle
                      const Text('Tipe Transaksi', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() {
                                selectedType = Category.typeIncome;
                                selectedCategory = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: selectedType == Category.typeIncome
                                      ? AppColors.income
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedType == Category.typeIncome
                                        ? AppColors.income
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: selectedType == Category.typeIncome
                                          ? const Color(0xFF0D0D0D)
                                          : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedType == Category.typeIncome
                                            ? const Color(0xFF0D0D0D)
                                            : AppColors.textSecondary,
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
                              onTap: () => setModalState(() {
                                selectedType = Category.typeExpense;
                                selectedCategory = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: selectedType == Category.typeExpense
                                      ? AppColors.expense
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedType == Category.typeExpense
                                        ? AppColors.expense
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: selectedType == Category.typeExpense
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedType == Category.typeExpense
                                            ? Colors.white
                                            : AppColors.textSecondary,
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

                      // Category Dropdown with Add Button
                      const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Category>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: AppColors.surface,
                                  hint: const Text('Pilih Kategori', style: TextStyle(color: AppColors.textSecondary)),
                                  items: categories.map((category) {
                                    return DropdownMenuItem<Category>(
                                      value: category,
                                      child: Text(category.name, style: const TextStyle(color: AppColors.textPrimary)),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setModalState(() => selectedCategory = value),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Add Category Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showAddCategoryDialog(context, selectedType, setModalState),
                              icon: const Icon(Icons.add, color: Color(0xFF0D0D0D)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title Input
                      const Text('Judul', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Gaji Bulanan',
                          prefixIcon: Icon(Icons.edit),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Judul tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Amount Input
                      const Text('Nominal (Rp)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 500000',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nominal tidak boleh kosong';
                          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                          if (int.parse(value) <= 0) return 'Nominal harus lebih dari 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date & Time Picker
                      const Text('Tanggal & Waktu', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          // Pick Date
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primary,
                                    onPrimary: Color(0xFF0D0D0D),
                                    surface: AppColors.surface,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          
                          if (date != null && context.mounted) {
                            // Pick Time
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: Color(0xFF0D0D0D),
                                      surface: AppColors.surface,
                                      onSurface: AppColors.textPrimary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            
                            if (time != null) {
                              setModalState(() {
                                selectedDateTime = DateTime(
                                  date.year, date.month, date.day,
                                  time.hour, time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(selectedDateTime),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (selectedCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pilih kategori terlebih dahulu'), backgroundColor: AppColors.expense),
                                );
                                return;
                              }

                              final transaction = Transaction(
                                title: titleController.text.trim(),
                                amount: int.parse(amountController.text),
                                categoryId: selectedCategory!.id!,
                                date: selectedDateTime.toIso8601String(),
                                category: selectedCategory,
                              );

                              final success = await context.read<TransactionProvider>().addTransaction(transaction);

                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Transaksi "${transaction.title}" berhasil ditambahkan!'),
                                    backgroundColor: AppColors.income,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: const Color(0xFF0D0D0D),
                          ),
                          child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD CATEGORY DIALOG
  // ============================================================

  void _showAddCategoryDialog(BuildContext context, int type, StateSetter setModalState) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Tambah Kategori ${type == Category.typeIncome ? "Pemasukan" : "Pengeluaran"}',
          style: const TextStyle(fontSize: 18),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nama kategori baru',
            filled: true,
            fillColor: AppColors.surfaceLight,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final category = Category(
                  name: nameController.text.trim(),
                  type: type,
                );
                
                final success = await context.read<TransactionProvider>().addCategory(category);
                
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  setModalState(() {}); // Refresh dropdown
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori "${category.name}" berhasil ditambahkan!'),
                        backgroundColor: AppColors.income,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0D0D0D),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
