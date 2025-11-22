import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/utils/colors.dart';
import 'package:intl/intl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalTestsThisMonth = 0;
  Map<String, int> _monthlyTestCounts = {};
  Map<String, Map<String, int>> _testTypesByMonth = {};
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      _totalUsers = usersSnapshot.docs.length;

      // Get test data for last 6 months
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
      
      _monthlyTestCounts = {};
      _testTypesByMonth = {};

      // Initialize months
      for (int i = 0; i < 6; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM yyyy').format(month);
        _monthlyTestCounts[monthKey] = 0;
        _testTypesByMonth[monthKey] = {
          'BMI': 0,
          'Big Five': 0,
          'Burnout': 0,
        };
      }

      // Count tests for each user
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        // BMI tests
        final bmiTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('bmi_tests')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
            .get();

        for (var test in bmiTests.docs) {
          final completedAt = (test.data()['completedAt'] as Timestamp).toDate();
          final monthKey = DateFormat('MMM yyyy').format(completedAt);
          if (_monthlyTestCounts.containsKey(monthKey)) {
            _monthlyTestCounts[monthKey] = (_monthlyTestCounts[monthKey] ?? 0) + 1;
            _testTypesByMonth[monthKey]!['BMI'] = (_testTypesByMonth[monthKey]!['BMI'] ?? 0) + 1;
          }
        }

        // Big Five tests
        final bigFiveTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('bigfive_tests')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
            .get();

        for (var test in bigFiveTests.docs) {
          final completedAt = (test.data()['completedAt'] as Timestamp).toDate();
          final monthKey = DateFormat('MMM yyyy').format(completedAt);
          if (_monthlyTestCounts.containsKey(monthKey)) {
            _monthlyTestCounts[monthKey] = (_monthlyTestCounts[monthKey] ?? 0) + 1;
            _testTypesByMonth[monthKey]!['Big Five'] = (_testTypesByMonth[monthKey]!['Big Five'] ?? 0) + 1;
          }
        }

        // Burnout tests
        final burnoutTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('burnout_tests')
            .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
            .get();

        for (var test in burnoutTests.docs) {
          final completedAt = (test.data()['completedAt'] as Timestamp).toDate();
          final monthKey = DateFormat('MMM yyyy').format(completedAt);
          if (_monthlyTestCounts.containsKey(monthKey)) {
            _monthlyTestCounts[monthKey] = (_monthlyTestCounts[monthKey] ?? 0) + 1;
            _testTypesByMonth[monthKey]!['Burnout'] = (_testTypesByMonth[monthKey]!['Burnout'] ?? 0) + 1;
          }
        }
      }

      // Calculate this month's total
      final currentMonthKey = DateFormat('MMM yyyy').format(now);
      _totalTestsThisMonth = _monthlyTestCounts[currentMonthKey] ?? 0;

    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header with gradient
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColorLight,
                              AppColors.primaryColor,
                              AppColors.primaryColorDark,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -30,
                              right: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.07),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dashboard Admin',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pantau statistik dan aktivitas tes',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.assessment,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KPI Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildKPICard(
                                    title: 'Total Pengguna',
                                    value: '$_totalUsers',
                                    icon: Icons.people,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildKPICard(
                                    title: 'Tests Bulan Ini',
                                    value: '$_totalTestsThisMonth',
                                    icon: Icons.assignment_turned_in,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Monthly Chart Title
                            const Text(
                              'Grafik Tes Per Bulan (6 Bulan Terakhir)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bar Chart
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              height: 300,
                              child: _buildBarChart(),
                            ),

                            const SizedBox(height: 24),

                            // Test Types Breakdown
                            const Text(
                              'Breakdown Tipe Tes Bulan Ini',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildTestTypesBreakdown(),
                            
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_monthlyTestCounts.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    final sortedMonths = _monthlyTestCounts.keys.toList();
    sortedMonths.sort((a, b) {
      final dateA = DateFormat('MMM yyyy').parse(a);
      final dateB = DateFormat('MMM yyyy').parse(b);
      return dateA.compareTo(dateB);
    });

    final maxValue = _monthlyTestCounts.values.isEmpty 
        ? 10.0 
        : (_monthlyTestCounts.values.reduce((a, b) => a > b ? a : b) + 5).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = sortedMonths[groupIndex];
              return BarTooltipItem(
                '$month\n${rod.toY.toInt()} tests',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedMonths.length) return const Text('');
                final month = sortedMonths[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.split(' ')[0],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          sortedMonths.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (_monthlyTestCounts[sortedMonths[index]] ?? 0).toDouble(),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColorLight, AppColors.primaryColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestTypesBreakdown() {
    final now = DateTime.now();
    final currentMonthKey = DateFormat('MMM yyyy').format(now);
    final testTypes = _testTypesByMonth[currentMonthKey] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildTestTypeRow('BMI Test', testTypes['BMI'] ?? 0, Colors.blue),
          const Divider(height: 32),
          _buildTestTypeRow('Big Five', testTypes['Big Five'] ?? 0, Colors.purple),
          const Divider(height: 32),
          _buildTestTypeRow('Burnout', testTypes['Burnout'] ?? 0, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTestTypeRow(String name, int count, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 8),
        Text('tes', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
