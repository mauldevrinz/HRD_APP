import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart';
import 'package:app/utils/test_result_storage.dart';

class BMITestPage extends StatefulWidget {
  const BMITestPage({Key? key}) : super(key: key);

  @override
  State<BMITestPage> createState() => _BMITestPageState();
}

class _BMITestPageState extends State<BMITestPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  double? _bmiResult;
  String _bmiCategory = '';
  String _bmiDescription = '';
  Color _categoryColor = Colors.grey;

  void _calculateBMI() async {
    if (_formKey.currentState!.validate()) {
      final double height = double.parse(_heightController.text) / 100; // Convert cm to m
      final double weight = double.parse(_weightController.text);
      
      setState(() {
        _bmiResult = weight / (height * height);
        _setBMICategory();
      });
      
      // Simpan hasil tes ke storage
      await TestResultStorage.saveTestResult(
        testTitle: 'Tes Body Mass Index',
        status: 'Selesai',
        iconName: 'monitor_weight_outlined',
        resultData: {
          'bmi': _bmiResult,
          'category': _bmiCategory,
          'height': double.parse(_heightController.text),
          'weight': weight,
          'description': _bmiDescription,
          'categoryColor': _categoryColor.value,
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
  }

  void _setBMICategory() {
    if (_bmiResult! < 18.5) {
      _bmiCategory = 'Kekurangan Berat Badan';
      _bmiDescription = 'BMI Anda menunjukkan berat badan kurang. Disarankan untuk meningkatkan asupan nutrisi seimbang.';
      _categoryColor = Colors.blue;
    } else if (_bmiResult! < 25) {
      _bmiCategory = 'Normal';
      _bmiDescription = 'Selamat! BMI Anda dalam kategori normal. Pertahankan pola hidup sehat.';
      _categoryColor = Colors.green;
    } else if (_bmiResult! < 30) {
      _bmiCategory = 'Kelebihan Berat Badan';
      _bmiDescription = 'BMI Anda menunjukkan kelebihan berat badan. Disarankan untuk mengatur pola makan dan olahraga.';
      _categoryColor = Colors.orange;
    } else {
      _bmiCategory = 'Obesitas';
      _bmiDescription = 'BMI Anda dalam kategori obesitas. Sangat disarankan untuk berkonsultasi dengan ahli gizi.';
      _categoryColor = Colors.red;
    }
  }

  void _resetForm() {
    setState(() {
      _heightController.clear();
      _weightController.clear();
      _bmiResult = null;
      _bmiCategory = '';
      _bmiDescription = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tes Body Mass Index',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
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
                      Icons.local_hospital_outlined,
                      size: 48,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hitung BMI Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan tinggi dan berat badan Anda untuk mengetahui status BMI',
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
              
              // Input Fields
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Diri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Height Input
                    Text(
                      'Tinggi Badan (cm)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 170',
                        prefixIcon: Icon(Icons.height, color: AppColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan tinggi badan Anda';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Masukkan tinggi badan yang valid (100-250 cm)';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Weight Input
                    Text(
                      'Berat Badan (kg)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 65',
                        prefixIcon: Icon(Icons.monitor_weight, color: AppColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan berat badan Anda';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 20 || weight > 300) {
                          return 'Masukkan berat badan yang valid (20-300 kg)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Calculate Button
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
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 40,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: -8,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      ElevatedButton(
                    onPressed: _calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Hitung BMI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
              
              // Result Section
              if (_bmiResult != null) ...[
                const SizedBox(height: 24),
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
                      Text(
                        'Hasil BMI Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // BMI Score
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _bmiResult!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _categoryColor,
                              ),
                            ),
                            Text(
                              _bmiCategory,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        _bmiDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Reset Button
                      OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.primaryColor),
                        ),
                        child: Text(
                          'Hitung Ulang',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}