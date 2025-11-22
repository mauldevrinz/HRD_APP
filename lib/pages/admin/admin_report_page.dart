import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/utils/colors.dart';
import 'package:intl/intl.dart';

class UserTestData {
  final String userId;
  final String userName;
  final String userEmail;
  final int bmiTestsCount;
  final int bigFiveTestsCount;
  final int burnoutTestsCount;
  final DateTime? lastTestDate;

  UserTestData({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bmiTestsCount,
    required this.bigFiveTestsCount,
    required this.burnoutTestsCount,
    this.lastTestDate,
  });

  int get totalTests => bmiTestsCount + bigFiveTestsCount + burnoutTestsCount;
}

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({Key? key}) : super(key: key);

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  List<UserTestData> _usersTestData = [];
  List<UserTestData> _filteredData = [];
  String _searchQuery = '';
  String _sortBy = 'name'; // name, tests, lastTest
  
  @override
  void initState() {
    super.initState();
    _loadUserTestData();
  }

  Future<void> _loadUserTestData() async {
    setState(() => _isLoading = true);

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final List<UserTestData> tempData = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        
        // Skip admin user
        if (userData['role'] == 'admin') continue;

        final userName = userData['name'] ?? 'Unknown';
        final userEmail = userData['email'] ?? 'Unknown';

        // Count BMI tests
        final bmiTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('bmi_tests')
            .get();
        final bmiCount = bmiTests.docs.length;

        // Count Big Five tests
        final bigFiveTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('bigfive_tests')
            .get();
        final bigFiveCount = bigFiveTests.docs.length;

        // Count Burnout tests
        final burnoutTests = await _firestore
            .collection('users')
            .doc(userId)
            .collection('burnout_tests')
            .get();
        final burnoutCount = burnoutTests.docs.length;

        // Get last test date
        DateTime? lastTestDate;
        final allTests = [
          ...bmiTests.docs.map((doc) => (doc.data()['completedAt'] as Timestamp?)?.toDate()),
          ...bigFiveTests.docs.map((doc) => (doc.data()['completedAt'] as Timestamp?)?.toDate()),
          ...burnoutTests.docs.map((doc) => (doc.data()['completedAt'] as Timestamp?)?.toDate()),
        ];
        
        allTests.removeWhere((date) => date == null);
        if (allTests.isNotEmpty) {
          lastTestDate = allTests.cast<DateTime>().reduce((a, b) => a.isAfter(b) ? a : b);
        }

        // Only add users who have completed at least one test
        if (bmiCount > 0 || bigFiveCount > 0 || burnoutCount > 0) {
          tempData.add(UserTestData(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            bmiTestsCount: bmiCount,
            bigFiveTestsCount: bigFiveCount,
            burnoutTestsCount: burnoutCount,
            lastTestDate: lastTestDate,
          ));
        }
      }

      // Sort by name by default
      tempData.sort((a, b) => a.userName.compareTo(b.userName));

      setState(() {
        _usersTestData = tempData;
        _filteredData = tempData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user test data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterAndSort() {
    var filtered = _usersTestData.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.userName.toLowerCase().contains(query) ||
             user.userEmail.toLowerCase().contains(query);
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.userName.compareTo(b.userName));
        break;
      case 'tests':
        filtered.sort((a, b) => b.totalTests.compareTo(a.totalTests));
        break;
      case 'lastTest':
        filtered.sort((a, b) {
          final dateA = a.lastTestDate ?? DateTime(2000);
          final dateB = b.lastTestDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
    }

    setState(() => _filteredData = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Laporan Pengguna',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Daftar pengguna yang telah mengisi tes',
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
                                  child: Icon(
                                    Icons.assignment_turned_in,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Total Pengguna: ${_filteredData.length}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search and Filter
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search
                        TextField(
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterAndSort();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau email pengguna...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Sort Options
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSortChip('Nama', 'name'),
                              const SizedBox(width: 8),
                              _buildSortChip('Total Tes', 'tests'),
                              const SizedBox(width: 8),
                              _buildSortChip('Tes Terakhir', 'lastTest'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of Users
                  Expanded(
                    child: _filteredData.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredData.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(_filteredData[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _sortBy = value);
        _filterAndSort();
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryColor,
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
        width: 1.2,
      ),
    );
  }

  Widget _buildUserCard(UserTestData userData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryColorLight, AppColors.primaryColor],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              userData.userName.isNotEmpty ? userData.userName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          userData.userName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        subtitle: Text(
          userData.userEmail,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${userData.totalTests} tes',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                
                // Test counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTestCountColumn('BMI', userData.bmiTestsCount, Colors.blue),
                    _buildTestCountColumn('Big Five', userData.bigFiveTestsCount, Colors.purple),
                    _buildTestCountColumn('Burnout', userData.burnoutTestsCount, Colors.orange),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Last test date
                if (userData.lastTestDate != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tes Terakhir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMM yyyy - HH:mm').format(userData.lastTestDate!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCountColumn(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.assignment, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.assignment_outlined,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada pengguna yang cocok dengan pencarian'
                  : 'Belum ada pengguna yang mengisi tes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
