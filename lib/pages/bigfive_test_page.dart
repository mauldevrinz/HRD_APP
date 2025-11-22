import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart';
import 'package:app/utils/test_result_storage.dart';

class BigFiveTestPage extends StatefulWidget {
  const BigFiveTestPage({Key? key}) : super(key: key);

  @override
  State<BigFiveTestPage> createState() => _BigFiveTestPageState();
}

class _BigFiveTestPageState extends State<BigFiveTestPage> {
  int _currentQuestionIndex = 0;
  Map<String, List<int>> _scores = {
    'openness': [],
    'conscientiousness': [],
    'extraversion': [],
    'agreeableness': [],
    'neuroticism': [],
  };
  
  bool _isCompleted = false;
  Map<String, double> _results = {};

  final List<Map<String, dynamic>> _questions = [
    // Openness questions
    {'text': 'Saya suka mencoba hal-hal baru dan petualangan', 'dimension': 'openness', 'reverse': false},
    {'text': 'Saya memiliki imajinasi yang aktif', 'dimension': 'openness', 'reverse': false},
    {'text': 'Saya lebih suka rutinitas yang sudah familiar', 'dimension': 'openness', 'reverse': true},
    {'text': 'Saya tertarik dengan ide-ide abstrak', 'dimension': 'openness', 'reverse': false},
    
    // Conscientiousness questions
    {'text': 'Saya selalu menyelesaikan tugas tepat waktu', 'dimension': 'conscientiousness', 'reverse': false},
    {'text': 'Saya orang yang terorganisir dan rapi', 'dimension': 'conscientiousness', 'reverse': false},
    {'text': 'Saya sering menunda-nunda pekerjaan', 'dimension': 'conscientiousness', 'reverse': true},
    {'text': 'Saya membuat rencana detail sebelum bertindak', 'dimension': 'conscientiousness', 'reverse': false},
    
    // Extraversion questions
    {'text': 'Saya mudah bergaul dengan orang baru', 'dimension': 'extraversion', 'reverse': false},
    {'text': 'Saya merasa nyaman menjadi pusat perhatian', 'dimension': 'extraversion', 'reverse': false},
    {'text': 'Saya lebih suka menghabiskan waktu sendiri', 'dimension': 'extraversion', 'reverse': true},
    {'text': 'Saya senang berbicara di depan umum', 'dimension': 'extraversion', 'reverse': false},
    
    // Agreeableness questions
    {'text': 'Saya peduli dengan perasaan orang lain', 'dimension': 'agreeableness', 'reverse': false},
    {'text': 'Saya mudah memaafkan kesalahan orang lain', 'dimension': 'agreeableness', 'reverse': false},
    {'text': 'Saya sering bersikap skeptis terhadap orang lain', 'dimension': 'agreeableness', 'reverse': true},
    {'text': 'Saya senang membantu orang yang kesulitan', 'dimension': 'agreeableness', 'reverse': false},
    
    // Neuroticism questions
    {'text': 'Saya mudah merasa cemas atau khawatir', 'dimension': 'neuroticism', 'reverse': false},
    {'text': 'Saya sering merasa stres dalam situasi sulit', 'dimension': 'neuroticism', 'reverse': false},
    {'text': 'Saya tetap tenang dalam situasi yang menantang', 'dimension': 'neuroticism', 'reverse': true},
    {'text': 'Saya mudah tersinggung atau marah', 'dimension': 'neuroticism', 'reverse': false},
  ];

  void _answerQuestion(int score) {
    final question = _questions[_currentQuestionIndex];
    final dimension = question['dimension'] as String;
    final isReverse = question['reverse'] as bool;
    
    // Reverse score if needed (1->5, 2->4, 3->3, 4->2, 5->1)
    final finalScore = isReverse ? 6 - score : score;
    
    _scores[dimension]!.add(finalScore);
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _calculateResults();
    }
  }

  void _calculateResults() async {
    _results.clear();
    
    _scores.forEach((dimension, scores) {
      double average = scores.reduce((a, b) => a + b) / scores.length;
      _results[dimension] = average;
    });
    
    setState(() {
      _isCompleted = true;
    });
    
    // Simpan hasil tes
    await TestResultStorage.saveTestResult(
      testTitle: 'Tes Big Five Personality (OCEAN)',
      status: 'Selesai',
      iconName: 'psychology_outlined',
      resultData: {
        'dimensions': _results,
        'totalQuestions': _questions.length,
        'scores': _scores,
        'description': 'Profil kepribadian Anda telah dianalisis berdasarkan 5 dimensi utama.',
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

  String _getDimensionDescription(String dimension) {
    switch (dimension) {
      case 'openness':
        return 'Keterbukaan terhadap pengalaman baru, kreativitas, dan keingintahuan intelektual';
      case 'conscientiousness':
        return 'Kedisiplinan, keteraturan, dan tanggung jawab dalam menjalankan tugas';
      case 'extraversion':
        return 'Kecenderungan untuk bersosialisasi dan mencari stimulasi dari lingkungan luar';
      case 'agreeableness':
        return 'Kecenderungan untuk kooperatif, percaya, dan peduli terhadap orang lain';
      case 'neuroticism':
        return 'Kecenderungan untuk mengalami emosi negatif seperti kecemasan dan stres';
      default:
        return '';
    }
  }

  String _getScoreInterpretation(double score) {
    if (score >= 4.0) return 'Tinggi';
    if (score >= 3.0) return 'Sedang';
    return 'Rendah';
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.blue;
  }

  void _resetTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _scores = {
        'openness': [],
        'conscientiousness': [],
        'extraversion': [],
        'agreeableness': [],
        'neuroticism': [],
      };
      _isCompleted = false;
      _results.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tes Big Five Personality',
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
    final currentQuestion = _questions[_currentQuestionIndex];
    
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
                  Icons.psychology_outlined,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  currentQuestion['text'],
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
                  children: [
                    _buildAnswerOption('Sangat Tidak Setuju', 1),
                    const SizedBox(height: 12),
                    _buildAnswerOption('Tidak Setuju', 2),
                    const SizedBox(height: 12),
                    _buildAnswerOption('Netral', 3),
                    const SizedBox(height: 12),
                    _buildAnswerOption('Setuju', 4),
                    const SizedBox(height: 12),
                    _buildAnswerOption('Sangat Setuju', 5),
                  ],
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
                  Icons.psychology,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hasil Tes Kepribadian Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Berikut adalah profil kepribadian Big Five (OCEAN) Anda',
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
          
          // Results
          ..._results.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildResultCard(entry.key, entry.value),
            );
          }).toList(),
          
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

  Widget _buildResultCard(String dimension, double score) {
    final dimensionNames = {
      'openness': 'Openness (Keterbukaan)',
      'conscientiousness': 'Conscientiousness (Kehati-hatian)',
      'extraversion': 'Extraversion (Ekstraversi)',
      'agreeableness': 'Agreeableness (Keramahan)',
      'neuroticism': 'Neuroticism (Neurotisisme)',
    };
    
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dimensionNames[dimension] ?? dimension,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getScoreInterpretation(score),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDimensionDescription(dimension),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score / 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${score.toStringAsFixed(1)}/5.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}