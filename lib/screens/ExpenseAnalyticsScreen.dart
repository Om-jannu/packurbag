import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseAnalyticsScreen extends StatefulWidget {
  final String serverIp;
  final String userId;

  const ExpenseAnalyticsScreen({
    Key? key,
    required this.serverIp,
    required this.userId,
  }) : super(key: key);

  @override
  _ExpenseAnalyticsScreenState createState() => _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _expenses = [];
  Map<String, double> _categoryTotals = {};
  Map<String, double> _monthlyTotals = {};
  double _totalSpent = 0;
  double _averageExpense = 0;
  double _highestExpense = 0;
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'Last 6 Months', 'All Time'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${widget.serverIp}/expenses/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _expenses = data.cast<Map<String, dynamic>>();
          _analyzeExpenses();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load expenses';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading expenses: $e';
        _isLoading = false;
      });
    }
  }

  void _analyzeExpenses() {
    _categoryTotals.clear();
    _monthlyTotals.clear();
    _totalSpent = 0;
    _highestExpense = 0;

    final now = DateTime.now();
    final filteredExpenses = _expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      switch (_selectedPeriod) {
        case 'Last 7 Days':
          return now.difference(expenseDate).inDays <= 7;
        case 'Last 30 Days':
          return now.difference(expenseDate).inDays <= 30;
        case 'Last 3 Months':
          return now.difference(expenseDate).inDays <= 90;
        case 'Last 6 Months':
          return now.difference(expenseDate).inDays <= 180;
        default:
          return true;
      }
    }).toList();

    for (var expense in filteredExpenses) {
      final amount = expense['amount'].toDouble();
      final category = expense['category'];
      final date = DateTime.parse(expense['date']);
      final monthKey = DateFormat('MMM yyyy').format(date);

      _totalSpent += amount;
      _highestExpense = amount > _highestExpense ? amount : _highestExpense;

      _categoryTotals[category] = (_categoryTotals[category] ?? 0) + amount;
      _monthlyTotals[monthKey] = (_monthlyTotals[monthKey] ?? 0) + amount;
    }

    _averageExpense = filteredExpenses.isEmpty ? 0 : _totalSpent / filteredExpenses.length;
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Spent',
          '₹${_totalSpent.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Average Expense',
          '₹${_averageExpense.toStringAsFixed(2)}',
          Icons.analytics,
          Colors.green,
        ),
        _buildSummaryCard(
          'Highest Expense',
          '₹${_highestExpense.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Total Transactions',
          _expenses.length.toString(),
          Icons.receipt_long,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sortedCategories.map((entry) {
                    final percentage = (entry.value / _totalSpent * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '$percentage%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / _totalSpent * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.primaries[sortedCategories.indexOf(entry) % Colors.primaries.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.key),
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text('($percentage%)'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    final sortedMonths = _monthlyTotals.entries.toList()
      ..sort((a, b) => DateFormat('MMM yyyy').parse(a.key).compareTo(DateFormat('MMM yyyy').parse(b.key)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('₹${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                            return Text(sortedMonths[value.toInt()].key);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedMonths.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses() {
    final recentExpenses = _expenses
      ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recentExpenses.take(5).map((expense) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[
                    _categoryTotals.keys.toList().indexOf(expense['category']) % Colors.primaries.length
                  ],
                  child: Text(
                    expense['category'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(expense['description']),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(expense['date'])),
                ),
                trailing: Text(
                  '₹${expense['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            items: _periods.map((period) {
              return DropdownMenuItem<String>(
                value: period,
                child: Text(period),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                  _analyzeExpenses();
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _loadExpenses,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 16),
                        _buildCategoryBreakdown(),
                        const SizedBox(height: 16),
                        _buildMonthlyTrend(),
                        const SizedBox(height: 16),
                        _buildRecentExpenses(),
                      ],
                    ),
                  ),
                ),
    );
  }
} 