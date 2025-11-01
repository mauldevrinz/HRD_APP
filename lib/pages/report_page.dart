import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class ReportData {
  final String title;
  final String date;
  final String status;
  final IconData icon;
  final Color statusColor;

  ReportData({
    required this.title,
    required this.date,
    required this.status,
    required this.icon,
    required this.statusColor,
  });
}

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<ReportData> reports = [
    ReportData(
      title: 'Tes Body Mass Index',
      date: '29 Okt 2025',
      status: 'Selesai',
      icon: Icons.local_hospital_outlined,
      statusColor: Colors.green,
    ),
    ReportData(
      title: 'Tes Big Five Personality (OCEAN)',
      date: '30 Okt 2025',
      status: 'Dalam Review',
      icon: Icons.local_fire_department_outlined,
      statusColor: Colors.orange,
    ),
    ReportData(
      title: 'Tes Burnout (Kelelahan)',
      date: '31 Okt 2025',
      status: 'Pending',
      icon: Icons.health_and_safety_outlined,
      statusColor: Colors.grey,
    ),
  ];

  // HAPUS 'Dalam Review' dari filter
  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Selesai', 'Pending']; // <-- 'Dalam Review' dihapus

  List<ReportData> get filteredReports {
    if (selectedFilter == 'Semua') return reports;
    return reports.where((r) => r.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // === Statistik Card (Tetap menampilkan data Dalam Review) ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColorLight,
                    AppColors.primaryColorDark,
                  ],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Total',
                    '${reports.length}',
                    Icons.assessment,
                  ),
                  _buildStatItem(
                    'Selesai',
                    '${reports.where((r) => r.status == 'Selesai').length}',
                    Icons.check_circle_outline,
                  ),
                  _buildStatItem(
                    'Pending',
                    '${reports.where((r) => r.status == 'Pending').length}',
                    Icons.pending_outlined,
                  ),
                ],
              ),
            ),

            // === Filter Chips (TANPA "Dalam Review") ===
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

            // === List Report ===
            Expanded(
              child: filteredReports.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return _buildReportCard(context, report);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // === Stat Item ===
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // === Report Card ===
  Widget _buildReportCard(BuildContext context, ReportData report) {
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
          onTap: () => _showReportDetailDialog(context, report),
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
                    report.icon,
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
                        report.title,
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
                            report.date,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: report.statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: report.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Empty View ===
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada laporan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba filter lain',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // === Dialog Detail (Tombol Lihat Detail tetap hilang untuk "Dalam Review") ===
  void _showReportDetailDialog(BuildContext context, ReportData report) {
    final bool isInReview = report.status == 'Dalam Review';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(report.icon, size: 48, color: AppColors.primaryColor),
                ),
                const SizedBox(height: 20),
                Text(
                  report.title,
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
                    color: report.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: report.statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Tanggal: ${report.date}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Tombol hanya untuk status bukan "Dalam Review"
                if (!isInReview)
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor),
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
                                AppColors.primaryColorDark,
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.visibility, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(child: Text('Membuka detail laporan...')),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Lihat Detail',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}