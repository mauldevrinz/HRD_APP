import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/test_result_storage.dart';
import 'package:app/utils/pdf_generator.dart';
import 'package:intl/intl.dart';

class TestResult {
  final String testTitle;
  final String date;
  final String status;
  final IconData icon;
  final Color statusColor;
  final Map<String, dynamic>? resultData;

  TestResult({
    required this.testTitle,
    required this.date,
    required this.status,
    required this.icon,
    required this.statusColor,
    this.resultData,
  });
}

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with WidgetsBindingObserver {
  List<TestResult> testResults = [];
  bool isLoading = true;

  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Selesai', 'Belum Dikerjakan'];
  
  // Daftar semua test yang tersedia di aplikasi
  final List<Map<String, dynamic>> _allTests = [
    {
      'title': 'Tes Body Mass Index',
      'icon': Icons.monitor_weight_outlined,
      'iconName': 'monitor_weight_outlined',
    },
    {
      'title': 'Tes Big Five Personality (OCEAN)',
      'icon': Icons.psychology_outlined,
      'iconName': 'psychology_outlined',
    },
    {
      'title': 'Tes Burnout (Kelelahan)',
      'icon': Icons.battery_alert_outlined,
      'iconName': 'battery_alert_outlined',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTestResults();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTestResults();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadTestResults() async {
    setState(() => isLoading = true);
    
    try {
      final results = await TestResultStorage.getTestResults();
      
      setState(() {
        testResults = results.map((data) {
          IconData icon;
          switch (data['iconName']) {
            case 'local_hospital_outlined':
              icon = Icons.local_hospital_outlined;
              break;
            case 'psychology_outlined':
              icon = Icons.psychology_outlined;
              break;
            case 'battery_alert_outlined':
              icon = Icons.battery_alert_outlined;
              break;
            case 'monitor_weight_outlined':
              icon = Icons.monitor_weight_outlined;
              break;
            default:
              icon = Icons.assessment;
          }
          
          final dateTime = DateTime.parse(data['date']);
          final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
          
          return TestResult(
            testTitle: data['testTitle'],
            date: formattedDate,
            status: data['status'],
            icon: icon,
            statusColor: data['status'] == 'Selesai' ? Colors.green : Colors.orange,
            resultData: data['resultData'],
          );
        }).toList();
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResults = [];
        isLoading = false;
      });
    }
  }

  List<TestResult> get filteredResults {
    // Jika filter "Semua" atau "Belum Dikerjakan", tampilkan semua 3 test
    if (selectedFilter == 'Semua' || selectedFilter == 'Belum Dikerjakan') {
      List<TestResult> allResults = [];
      
      // Loop semua test yang tersedia
      for (var test in _allTests) {
        // Cari apakah test ini sudah dikerjakan
        final existingTest = testResults.firstWhere(
          (r) => r.testTitle == test['title'],
          orElse: () => TestResult(
            testTitle: test['title'],
            date: DateFormat('dd MMM yyyy').format(DateTime.now()),
            status: 'Belum Dikerjakan',
            icon: test['icon'],
            statusColor: Colors.orange,
            resultData: null,
          ),
        );
        
        // Jika filter "Belum Dikerjakan", hanya tampilkan yang belum
        if (selectedFilter == 'Belum Dikerjakan') {
          if (existingTest.status == 'Belum Dikerjakan' || existingTest.status == 'Pending') {
            allResults.add(existingTest);
          }
        } else {
          // Filter "Semua", tampilkan semua
          allResults.add(existingTest);
        }
      }
      
      return allResults;
    }
    
    // Filter "Selesai"
    return testResults.where((r) => r.status == 'Selesai').toList();
  }
  
  Future<void> _exportToPdf() async {
    if (testResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada hasil tes untuk diekspor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final results = await TestResultStorage.getTestResults();
      await PdfGenerator.generateAndShareTestResults(results);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Hasil?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus SEMUA hasil tes? '
          'Tindakan ini tidak dapat dibatalkan dan semua data akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await TestResultStorage.clearAllResults();
      await _loadTestResults();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua hasil tes berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
        child: Column(
          children: [
            // Header with gradient (Fixed height)
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
                  stops: [0.0, 0.5, 1.0],
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
                  Positioned(
                    top: 50,
                    left: 40,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Laporan Assessment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hasil tes dan evaluasi Anda',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _exportToPdf,
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                                tooltip: 'Export PDF',
                              ),
                              IconButton(
                                onPressed: _loadTestResults,
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                tooltip: 'Refresh',
                              ),
                            ],
                          ),
                        ],
                      ),
                ],
              ),
                ],
              ),
            ),

            // Scrollable content area
            Expanded(
              child: filteredResults.isEmpty
                  ? _buildEmptyView()
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Statistics Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  'Total Tes',
                                  '3',
                                  Icons.assessment,
                                  AppColors.primaryColor,
                                ),
                                _buildStatItem(
                                  'Selesai',
                                  '${testResults.where((r) => r.status == 'Selesai').length}',
                                  Icons.check_circle_outline,
                                  Colors.green,
                                ),
                                _buildStatItem(
                                  'Belum',
                                  '${3 - testResults.where((r) => r.status == 'Selesai').length}',
                                  Icons.pending_outlined,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          
                          // Clear All Button
                          if (testResults.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _confirmClearAll,
                                  icon: const Icon(Icons.delete_sweep, size: 18),
                                  label: const Text('Hapus Semua Hasil'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Filter Chips
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: filters.map((filter) {
                                  final isSelected = selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: FilterChip(
                                      label: Text(filter),
                                      selected: isSelected,
                                      onSelected: (_) {
                                                      setState(() => selectedFilter = filter);
                                      },
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textColor,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                      backgroundColor: Colors.white,
                                      selectedColor: AppColors.primaryColor,
                                      checkmarkColor: Colors.white,
                                      elevation: isSelected ? 4 : 1,
                                      shadowColor: AppColors.primaryColor.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Results List
                          ...filteredResults.map((result) {
                            return _buildResultCard(context, result);
                          }).toList(),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, TestResult result) {
    final index = testResults.indexOf(result);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showResultDetailDialog(context, result),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    result.icon,
                    size: 28,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.testTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            result.date,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: result.statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: result.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                      onPressed: () => _confirmDeleteResult(context, index),
                      tooltip: 'Hapus',
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _confirmDeleteResult(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Hasil Tes?'),
        content: const Text('Apakah Anda yakin ingin menghapus hasil tes ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await TestResultStorage.deleteTestResult(index);
      await _loadTestResults();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasil tes berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assessment_outlined,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Hasil Tes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selesaikan assessment untuk melihat hasil dan evaluasi lengkap Anda di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mulai dari tab Home',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDetailDialog(BuildContext context, TestResult result) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(result.icon, size: 48, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result.testTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: result.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: result.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Tanggal: ${result.date}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display specific test results
                  if (result.resultData != null) ...[
                    _buildTestSpecificResults(result),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColorLight,
                                AppColors.primaryColor,
                                AppColors.primaryColorDark,
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showFullReportDialog(context, result);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              alignment: Alignment.center,
                            ),
                            child: const Text(
                              'Laporan Lengkap',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestSpecificResults(TestResult result) {
    final data = result.resultData!;
    
    switch (result.testTitle) {
      case 'Tes Body Mass Index':
        return _buildBMIResults(data);
      case 'Tes Big Five Personality (OCEAN)':
        return _buildBigFiveResults(data);
      case 'Tes Burnout (Kelelahan)':
        return _buildBurnoutResults(data);
      default:
        return Container();
    }
  }

  Widget _buildBMIResults(Map<String, dynamic> data) {
    final bmi = data['bmi'] as double;
    final category = data['category'] as String;
    final height = data['height'] as int;
    final weight = data['weight'] as int;
    
    Color categoryColor = Colors.green;
    if (bmi < 18.5) categoryColor = Colors.blue;
    else if (bmi >= 25 && bmi < 30) categoryColor = Colors.orange;
    else if (bmi >= 30) categoryColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: categoryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Tinggi', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text('$height cm', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  Text('Berat', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text('$weight kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigFiveResults(Map<String, dynamic> data) {
    final dimensions = data['dimensions'] as Map<String, dynamic>;
    final dimensionNames = {
      'openness': 'Openness',
      'conscientiousness': 'Conscientiousness',
      'extraversion': 'Extraversion',
      'agreeableness': 'Agreeableness',
      'neuroticism': 'Neuroticism',
    };

    return Column(
      children: dimensions.entries.map((entry) {
        final score = entry.value as double;
        final percentage = score / 5;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dimensionNames[entry.key] ?? entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    score.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                minHeight: 6,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBurnoutResults(Map<String, dynamic> data) {
    final score = data['burnoutScore'] as double;
    final level = data['level'] as String;
    
    Color levelColor = Colors.green;
    if (score >= 80) levelColor = Colors.red;
    else if (score >= 60) levelColor = Colors.orange;
    else if (score >= 40) levelColor = Colors.amber;
    else if (score >= 20) levelColor = Colors.lightGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${score.round()}%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: levelColor,
            ),
          ),
          Text(
            level,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: levelColor,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  void _showFullReportDialog(BuildContext context, TestResult result) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 700),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.description, size: 48, color: AppColors.primaryColor),
                        const SizedBox(height: 12),
                        Text(
                          'Laporan Lengkap',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          result.testTitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (result.resultData != null) ...[
                    Text(
                      'Hasil Tes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTestSpecificResults(result),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Deskripsi:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.resultData!['description'] ?? 'Tidak ada deskripsi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    
                    // Show recommendations for burnout test
                    if (result.testTitle == 'Tes Burnout (Kelelahan)' && 
                        result.resultData!['recommendations'] != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Rekomendasi:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(result.resultData!['recommendations'] as List<String>).map((rec) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColorLight,
                            AppColors.primaryColor,
                            AppColors.primaryColorDark,
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          alignment: Alignment.center,
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}