import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart';
import 'package:app/utils/test_result_storage.dart';

class BurnoutTestPage extends StatefulWidget {
  const BurnoutTestPage({Key? key}) : super(key: key);

  @override
  State<BurnoutTestPage> createState() => _BurnoutTestPageState();
}

class _BurnoutTestPageState extends State<BurnoutTestPage> {
  int _currentQuestionIndex = 0;
  List<int> _answers = [];
  bool _isCompleted = false;
  
  double _burnoutScore = 0;
  String _burnoutLevel = '';
  String _burnoutDescription = '';
  Color _levelColor = Colors.grey;

  final List<String> _questions = [
    'Saya merasa kelelahan secara emosional setelah bekerja atau belajar',
    'Saya sulit berkonsentrasi karena kelelahan mental',
    'Saya merasa tidak bersemangat dalam aktivitas sehari-hari',
    'Saya kesulitan tidur karena pikiran yang stres',
    'Saya merasa mudah marah atau frustrasi dengan hal-hal kecil',
    'Saya merasa seperti energi saya sudah habis terkuras',
    'Saya merasa skeptis atau sinis terhadap pekerjaan/tugas saya',
    'Saya merasa tidak efektif dalam menyelesaikan tugas',
    'Saya merasa tidak dihargai atas usaha yang saya lakukan',
    'Saya merasa terisolasi atau terpisah dari orang lain',
    'Saya sering merasa sakit kepala atau masalah fisik lainnya',
    'Saya merasa kehilangan motivasi untuk melakukan aktivitas',
    'Saya merasa seperti hidup saya tidak seimbang',
    'Saya merasa kewalahan dengan tanggung jawab yang ada',
    'Saya merasa pesimis tentang masa depan',
  ];

  final List<String> _scaleLabels = [
    'Tidak Pernah',
    'Jarang',
    'Kadang-kadang',
    'Sering',
    'Selalu',
  ];

  void _answerQuestion(int score) {
    _answers.add(score);
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _calculateResults();
    }
  }

  void _calculateResults() async {
    int totalScore = _answers.reduce((a, b) => a + b);
    double maxScore = (_questions.length * 5).toDouble();
    
    _burnoutScore = (totalScore / maxScore) * 100;
    
    if (_burnoutScore >= 80) {
      _burnoutLevel = 'Burnout Berat';
      _burnoutDescription = 'Tingkat burnout Anda sangat tinggi. Sangat disarankan untuk segera mencari bantuan profesional dan melakukan perubahan signifikan dalam gaya hidup Anda.';
      _levelColor = Colors.red;
    } else if (_burnoutScore >= 60) {
      _burnoutLevel = 'Burnout Sedang';
      _burnoutDescription = 'Anda mengalami burnout tingkat sedang. Penting untuk mulai menerapkan strategi manajemen stres dan mempertimbangkan untuk berkonsultasi dengan ahli.';
      _levelColor = Colors.orange;
    } else if (_burnoutScore >= 40) {
      _burnoutLevel = 'Risiko Burnout';
      _burnoutDescription = 'Anda berisiko mengalami burnout. Mulailah memperhatikan keseimbangan hidup dan terapkan teknik relaksasi untuk mencegah burnout yang lebih parah.';
      _levelColor = Colors.amber;
    } else if (_burnoutScore >= 20) {
      _burnoutLevel = 'Stres Ringan';
      _burnoutDescription = 'Anda mengalami tingkat stres yang normal. Tetap jaga keseimbangan hidup dan lakukan aktivitas yang menyenangkan untuk menjaga kesehatan mental.';
      _levelColor = Colors.lightGreen;
    } else {
      _burnoutLevel = 'Kondisi Baik';
      _burnoutDescription = 'Selamat! Tingkat burnout Anda rendah. Pertahankan gaya hidup sehat dan keseimbangan yang sudah Anda miliki.';
      _levelColor = Colors.green;
    }
    
    setState(() {
      _isCompleted = true;
    });
    
    // Simpan hasil tes
    await TestResultStorage.saveTestResult(
      testTitle: 'Tes Burnout (Kelelahan)',
      status: 'Selesai',
      iconName: 'battery_alert_outlined',
      resultData: {
        'burnoutScore': _burnoutScore,
        'level': _burnoutLevel,
        'levelColor': _levelColor.value,
        'totalQuestions': _questions.length,
        'description': _burnoutDescription,
        'recommendations': _getRecommendations(),
      },
    );
    
    // Tampilkan snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil tes berhasil disimpan!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  List<String> _getRecommendations() {
    if (_burnoutScore >= 80) {
      return [
        'Konsultasi dengan psikolog atau konselor profesional',
        'Pertimbangkan untuk mengambil cuti atau istirahat panjang',
        'Evaluasi ulang beban kerja dan tanggung jawab',
        'Cari dukungan dari keluarga dan teman dekat',
        'Praktikkan teknik relaksasi dan meditasi setiap hari',
      ];
    } else if (_burnoutScore >= 60) {
      return [
        'Atur prioritas dan kurangi beban kerja yang tidak perlu',
        'Luangkan waktu untuk istirahat dan hobi',
        'Lakukan olahraga ringan secara teratur',
        'Praktikkan teknik pernapasan dan mindfulness',
        'Bicarakan perasaan Anda dengan orang terdekat',
      ];
    } else if (_burnoutScore >= 40) {
      return [
        'Buat jadwal yang lebih seimbang antara kerja dan istirahat',
        'Lakukan aktivitas yang menyenangkan setiap hari',
        'Jaga pola tidur yang teratur (7-8 jam per hari)',
        'Batasi penggunaan gadget sebelum tidur',
        'Lakukan stretching atau yoga ringan',
      ];
    } else {
      return [
        'Pertahankan rutinitas sehat yang sudah ada',
        'Tetap jaga keseimbangan antara kerja dan istirahat',
        'Lanjutkan aktivitas fisik yang rutin',
        'Jaga hubungan sosial yang positif',
        'Monitor kondisi mental secara berkala',
      ];
    }
  }

  void _resetTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _isCompleted = false;
      _burnoutScore = 0;
      _burnoutLevel = '';
      _burnoutDescription = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tes Burnout (Kelelahan)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
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
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 50,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isCompleted ? _buildResultPage() : _buildQuestionPage(),
    );
  }

  Widget _buildQuestionPage() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Section
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Question Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _questions[_currentQuestionIndex],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Answer Options
                Column(
                  children: List.generate(_scaleLabels.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAnswerOption(_scaleLabels[index], index + 1),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String text, int score) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _answerQuestion(score),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResultPage() {
    final recommendations = _getRecommendations();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hasil Tes Burnout Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Evaluasi tingkat kelelahan dan stres yang Anda alami',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Score Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Text(
                  'Skor Burnout Anda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_burnoutScore.round()}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _levelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _burnoutLevel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _levelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _burnoutDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recommendations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi untuk Anda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...recommendations.map((recommendation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recommendation,
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
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetTest,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    'Ulangi Tes',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
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
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -8,
                        left: 20,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                    ),
                    child: const Center(
                      child: Text(
                        'Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}