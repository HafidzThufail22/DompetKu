import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';
import '../main.dart';

/// Halaman Pengaturan
/// Mengelola kategori transaksi
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Income Categories Section
                _buildSectionHeader(
                  context,
                  'Kategori Pemasukan',
                  Icons.arrow_downward,
                  AppColors.income,
                  () => _showAddCategoryDialog(context, Category.typeIncome),
                ),
                const SizedBox(height: 12),
                _buildCategoryList(
                  context,
                  provider.incomeCategories,
                  provider,
                  AppColors.income,
                ),
                const SizedBox(height: 24),

                // Expense Categories Section
                _buildSectionHeader(
                  context,
                  'Kategori Pengeluaran',
                  Icons.arrow_upward,
                  AppColors.expense,
                  () => _showAddCategoryDialog(context, Category.typeExpense),
                ),
                const SizedBox(height: 12),
                _buildCategoryList(
                  context,
                  provider.expenseCategories,
                  provider,
                  AppColors.expense,
                ),
                const SizedBox(height: 24),

                // App Info Section
                _buildAppInfo(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onAdd,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Color(0xFF0D0D0D)),
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<Category> categories,
    TransactionProvider provider,
    Color color,
  ) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada kategori',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          final transactionCount = provider.getTransactionCountByCategory(category.id!);
          final canDelete = provider.canDeleteCategory(category.id!);

          return Dismissible(
            key: Key('category_${category.id}'),
            direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.expense,
                borderRadius: index == categories.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (!canDelete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tidak bisa hapus: ada $transactionCount transaksi'),
                    backgroundColor: AppColors.expense,
                  ),
                );
                return false;
              }
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Hapus Kategori'),
                  content: Text('Yakin ingin menghapus "${category.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              final success = await provider.deleteCategory(category.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kategori "${category.name}" dihapus')),
                );
              }
            },
            child: InkWell(
              onTap: () => _showEditCategoryDialog(context, category),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: index < categories.length - 1
                      ? Border(bottom: BorderSide(color: AppColors.border))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          category.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$transactionCount transaksi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary.withAlpha(128),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, int type) {
    final nameController = TextEditingController();
    final typeName = type == Category.typeIncome ? 'Pemasukan' : 'Pengeluaran';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Tambah Kategori $typeName'),
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
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori "${category.name}" ditambahkan'),
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
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nama kategori',
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
                final updatedCategory = Category(
                  id: category.id,
                  name: nameController.text.trim(),
                  type: category.type,
                );
                final success = await context.read<TransactionProvider>().updateCategory(updatedCategory);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kategori berhasil diupdate'),
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
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF0D0D0D),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DompetKu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Versi 1.0.0',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aplikasi pencatatan keuangan pribadi',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
