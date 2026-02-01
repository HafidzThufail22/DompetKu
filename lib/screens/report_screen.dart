import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';
import '../main.dart';

/// Halaman Laporan dengan PieChart
/// Menampilkan statistik pengeluaran per kategori
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int? _touchedIndex;

  // Warna untuk chart
  final List<Color> _chartColors = [
    const Color(0xFFFF6B6B), // Merah
    const Color(0xFF4ECDC4), // Tosca
    const Color(0xFFFFE66D), // Kuning
    const Color(0xFF95E1D3), // Hijau muda
    const Color(0xFFF38181), // Pink
    const Color(0xFFAA96DA), // Ungu
    const Color(0xFFFCBF49), // Orange
    const Color(0xFF2EC4B6), // Cyan
    const Color(0xFFE71D36), // Merah tua
    const Color(0xFF7209B7), // Ungu tua
  ];

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final expenseData = provider.getExpensesByCategory();
          final incomeData = provider.getIncomeByCategory();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector
                _buildMonthSelector(provider),
                const SizedBox(height: 24),

                // Summary Cards
                _buildSummaryCards(provider),
                const SizedBox(height: 24),

                // Expense Chart Section
                if (expenseData.isNotEmpty) ...[
                  _buildSectionTitle('Pengeluaran per Kategori'),
                  const SizedBox(height: 16),
                  _buildPieChart(expenseData, isExpense: true),
                  const SizedBox(height: 16),
                  _buildCategoryList(expenseData, isExpense: true),
                  const SizedBox(height: 24),
                ],

                // Income Chart Section
                if (incomeData.isNotEmpty) ...[
                  _buildSectionTitle('Pemasukan per Kategori'),
                  const SizedBox(height: 16),
                  _buildPieChart(incomeData, isExpense: false),
                  const SizedBox(height: 16),
                  _buildCategoryList(incomeData, isExpense: false),
                ],

                // Empty State
                if (expenseData.isEmpty && incomeData.isEmpty)
                  _buildEmptyState(),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => provider.previousMonth(),
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
          GestureDetector(
            onTap: () => _showMonthPicker(context, provider),
            child: Column(
              children: [
                Text(
                  provider.selectedMonthName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.transactionCount} transaksi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.nextMonth(),
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, TransactionProvider provider) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - i, 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Bulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: months.map((month) {
                final isSelected = month.year == provider.selectedMonth.year &&
                    month.month == provider.selectedMonth.month;
                return GestureDetector(
                  onTap: () {
                    provider.setSelectedMonth(month);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('MMM yyyy', 'id_ID').format(month),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0D0D0D) : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Pemasukan',
            provider.monthlyIncome,
            AppColors.income,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Pengeluaran',
            provider.monthlyExpense,
            AppColors.expense,
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatRupiah(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data, {required bool isExpense}) {
    final total = data.fold<int>(0, (sum, item) => sum + (item['total'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _buildChartSections(data, total),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${formatRupiah(total)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(List<Map<String, dynamic>> data, int total) {
    return List.generate(data.length, (index) {
      final item = data[index];
      final amount = item['total'] as int;
      final percentage = (amount / total) * 100;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: _chartColors[index % _chartColors.length],
        value: amount.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> data, {required bool isExpense}) {
    final total = data.fold<int>(0, (sum, item) => sum + (item['total'] as int));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(data.length, (index) {
          final item = data[index];
          final category = item['category'] as Category?;
          final amount = item['total'] as int;
          final count = item['count'] as int;
          final percentage = (amount / total) * 100;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < data.length - 1
                  ? Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _chartColors[index % _chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$count transaksi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpense ? AppColors.expense : AppColors.income,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan transaksi di tab Beranda',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
