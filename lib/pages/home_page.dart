import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'bmi_test_page.dart';
import 'bigfive_test_page.dart';
import 'burnout_test_page.dart';

// Custom Color Palette - ColorHunt Inspired
class ColorTheme {
  static const Color primaryDark = Color(0xFF154D71);    // Deep Blue
  static const Color primary = Color(0xFF1C6EA4);        // Blue
  static const Color primaryLight = Color(0xFF33A1E0);   // Light Blue
  static const Color accent = Color(0xFFFFF9AF);         // Light Yellow
  static const Color purple = Color(0xFF8B5CF6);         // Purple
  static const Color purpleLight = Color(0xFFA78BFA);    // Light Purple
  static const Color purpleDark = Color(0xFF7C3AED);     // Dark Purple
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
}

class Assessment {
  final String title;
  final String shortTitle;
  final IconData icon;
  final String schedule;
  final DateTime date;
  final VoidCallback onTap;
  final String description;
  final String estimatedTime;
  final String difficulty;
  final Color accentColor;

  const Assessment({
    required this.title,
    required this.shortTitle,
    required this.icon,
    required this.schedule,
    required this.date,
    required this.onTap,
    required this.description,
    required this.estimatedTime,
    required this.difficulty,
    required this.accentColor,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Assessment> _assessments = [];
  List<Assessment> _filteredAssessments = [];
  Set<String> _enabledNotifications = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAssessments();
    _filteredAssessments = _assessments;
    _startCardRotation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  void _startCardRotation() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _assessments.isNotEmpty) {
        setState(() {
          _currentCardIndex = (_currentCardIndex + 1) % _assessments.length;
        });
        _startCardRotation();
      }
    });
  }

  void _initializeAssessments() {
    _assessments = [
      Assessment(
        title: 'Tes Body Mass Index',
        shortTitle: 'BMI Assessment',
        icon: Icons.monitor_weight_outlined,
        schedule: 'Tersedia sekarang',
        date: DateTime.now(),
        description: 'Evaluasi status berat badan ideal dengan kalkulator BMI yang akurat',
        estimatedTime: '3 menit',
        difficulty: 'Mudah',
        accentColor: ColorTheme.primaryLight,
        onTap: () => _showTestDescriptionDialog(
          context,
          title: 'Tes Body Mass Index',
          icon: Icons.monitor_weight_outlined,
          description: 'Yuk, cari tahu status berat badanmu! Apakah sudah ideal, kurang, atau berlebih?\n\nTes ini akan membantu Anda menghitung Indeks Massa Tubuh (BMI) berdasarkan tinggi dan berat badan Anda untuk mengetahui kategori berat badan yang sehat.',
          estimatedTime: '3 menit',
          difficulty: 'Mudah',
          accentColor: ColorTheme.primaryLight,
          onStart: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BMITestPage()),
            );
          },
        ),
      ),
      Assessment(
        title: 'Tes Big Five Personality (OCEAN)',
        shortTitle: 'Personality Test',
        icon: Icons.psychology_outlined,
        schedule: 'Tersedia sekarang',
        date: DateTime.now(),
        description: 'Analisis mendalam kepribadian melalui lima dimensi psikologi',
        estimatedTime: '10 menit',
        difficulty: 'Sedang',
        accentColor: ColorTheme.primaryLight,
        onTap: () => _showTestDescriptionDialog(
          context,
          title: 'Tes Big Five Personality (OCEAN)',
          icon: Icons.psychology_outlined,
          description: 'Kenali dirimu lebih dalam! Tes ini akan mengukur 5 dimensi utama kepribadianmu:\n\n• Openness (Keterbukaan)\n• Conscientiousness (Kesadaran)\n• Extraversion (Ekstraversi)\n• Agreeableness (Keramahan)\n• Neuroticism (Neurotisisme)\n\nHasil tes akan membantu Anda memahami karakteristik dan pola perilaku Anda.',
          estimatedTime: '10 menit',
          difficulty: 'Sedang',
          accentColor: ColorTheme.primaryLight,
          onStart: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BigFiveTestPage()),
            );
          },
        ),
      ),
      Assessment(
        title: 'Tes Burnout (Kelelahan)',
        shortTitle: 'Burnout Assessment',
        icon: Icons.battery_alert_outlined,
        schedule: 'Tersedia sekarang',
        date: DateTime.now(),
        description: 'Evaluasi tingkat kelelahan mental dan fisik Anda',
        estimatedTime: '7 menit',
        difficulty: 'Mudah',
        accentColor: ColorTheme.primaryLight,
        onTap: () => _showTestDescriptionDialog(
          context,
          title: 'Tes Burnout (Kelelahan)',
          icon: Icons.battery_alert_outlined,
          description: 'Merasa lelah secara emosional, mental, atau fisik?\n\nTes ini akan mengukur tingkat kelelahanmu akibat stres kerja atau tekanan hidup. Burnout dapat mempengaruhi produktivitas, kesehatan mental, dan kualitas hidup Anda.\n\nSegera identifikasi gejala burnout dan temukan solusi yang tepat!',
          estimatedTime: '7 menit',
          difficulty: 'Mudah',
          accentColor: ColorTheme.primaryLight,
          onStart: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BurnoutTestPage()),
            );
          },
        ),
      ),
    ];
  }

  void _filterAssessments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAssessments = _assessments;
      } else {
        _filteredAssessments = _assessments
            .where((assessment) =>
                assessment.title.toLowerCase().contains(query.toLowerCase()) ||
                assessment.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        final userProfile = userProfileProvider.userProfile;
        
        return Scaffold(
          backgroundColor: ColorTheme.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Modern Header with new color palette
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ColorTheme.primaryLight,
                              ColorTheme.primary,
                              ColorTheme.primaryDark,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative pattern background
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 100,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.07),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 60,
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
                            Positioned(
                              bottom: 30,
                              right: 150,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.04),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 100,
                              left: 120,
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Top Bar
                                  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                ColorTheme.primaryLight,
                                                ColorTheme.accent,
                                                ColorTheme.purple,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ColorTheme.purple.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorTheme.surface,
                                              borderRadius: BorderRadius.circular(13),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(13),
                                              child: userProfile?.photoUrl != null
                                                  ? Image.network(
                                                      userProfile!.photoUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(
                                                          Icons.person_outline,
                                                          color: ColorTheme.primary,
                                                          size: 28,
                                                        );
                                                      },
                                                    )
                                                  : Icon(
                                                      Icons.person_outline,
                                                      color: ColorTheme.primary,
                                                      size: 28,
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
                                                _getGreeting(),
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (userProfile?.name ?? 'User').split(' ').first,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Notification button with accent color
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorTheme.accent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: ColorTheme.accent.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        InkWell(
                                          onTap: () => _showNotificationDialog(context),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              _enabledNotifications.isNotEmpty 
                                                  ? Icons.notifications
                                                  : Icons.notifications_none_outlined,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        if (_enabledNotifications.isNotEmpty)
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: ColorTheme.accent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Enhanced Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: ColorTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    hintText: 'Cari assessment...',
                                    hintStyle: TextStyle(
                                      color: ColorTheme.textLight,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: ColorTheme.primary,
                                      size: 22,
                                    ),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear_rounded,
                                              color: ColorTheme.textLight,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _filterAssessments('');
                                            },
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: _filterAssessments,
                                ),
                              ),
                            ],
                          ),
                        ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Quick Overview Card with new colors
                        _buildOverviewCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Featured Assessment Card
                        if (_assessments.isNotEmpty) ...[
                          _buildFeaturedCard(),
                          const SizedBox(height: 32),
                        ],
                        
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Semua Assessment',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: ColorTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pilih tes yang ingin Anda lakukan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ColorTheme.textLight,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            if (_searchController.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ColorTheme.accent.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_filteredAssessments.length} hasil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorTheme.primaryDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Assessment Cards
                        _filteredAssessments.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: _filteredAssessments.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final assessment = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index != _filteredAssessments.length - 1 ? 16 : 0,
                                    ),
                                    child: _buildColorfulTestCard(assessment, index),
                                  );
                                }).toList(),
                              ),
                        
                        const SizedBox(height: 40),
                      ]),
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

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.primaryDark.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildColorfulStatItem(
            icon: Icons.assignment_outlined,
            value: '${_assessments.length}',
            label: 'Tes Tersedia',
            color: ColorTheme.primary,
          ),
          _buildStatDivider(),
          _buildColorfulStatItem(
            icon: Icons.access_time_outlined,
            value: '20',
            label: 'Menit Total',
            color: ColorTheme.primaryLight,
          ),
          _buildStatDivider(),
          _buildColorfulStatItem(
            icon: Icons.notifications_outlined,
            value: '${_enabledNotifications.length}',
            label: 'Notifikasi',
            color: ColorTheme.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: ColorTheme.textLight,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: ColorTheme.textLight.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildFeaturedCard() {
    final featured = _assessments[_currentCardIndex];
    
    // Tentukan gradient berdasarkan card index - DIFFERENT COLORS IN BLUE THEME
    List<Color> gradientColors;
    Color buttonColor;
    
    if (_currentCardIndex == 0) {
      // Card 1 (BMI): Yellow/Amber - Warm & Energy
      gradientColors = [const Color(0xFFFBBC04), const Color(0xFFF59E0B)];
      buttonColor = const Color(0xFFD97706);
    } else if (_currentCardIndex == 1) {
      // Card 2 (Personality): Blue - Classic & Trust
      gradientColors = [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      buttonColor = const Color(0xFF1E40AF);
    } else {
      // Card 3 (Burnout): Purple - Calm & Wisdom
      gradientColors = [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      buttonColor = const Color(0xFF6D28D9);
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey(_currentCardIndex),
        constraints: const BoxConstraints(
          minHeight: 220,
          maxHeight: 240,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative pattern background - Enhanced
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: 60,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
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
              bottom: 20,
              left: 50,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 30,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 80,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 100,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Content
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    featured.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              featured.shortTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              featured.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildFeatureTag(Icons.access_time_outlined, featured.estimatedTime),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: featured.onTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mulai',
                              style: TextStyle(
                                color: buttonColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: buttonColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulTestCard(Assessment assessment, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: ColorTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: assessment.accentColor.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: assessment.accentColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: assessment.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Colorful Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                assessment.accentColor.withOpacity(0.1),
                                assessment.accentColor.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: assessment.accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            assessment.icon,
                            size: 26,
                            color: assessment.accentColor,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      assessment.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: ColorTheme.textDark,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  if (_enabledNotifications.contains(assessment.title))
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: ColorTheme.accent.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.notifications,
                                        size: 12,
                                        color: ColorTheme.primaryDark,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                assessment.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorTheme.textLight,
                                  height: 1.3,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              _buildColorfulInfoChip(
                                Icons.access_time_outlined,
                                assessment.estimatedTime,
                                assessment.accentColor,
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow with accent color
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: assessment.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: assessment.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorfulInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorTheme.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: ColorTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Assessment Tidak Ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci yang berbeda',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textLight,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _filterAssessments('');
            },
            icon: Icon(Icons.refresh_rounded, size: 18, color: ColorTheme.textDark),
            label: Text('Reset Pencarian', style: TextStyle(color: ColorTheme.textDark)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFBF0), // Putih tulang
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showTestDescriptionDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required String estimatedTime,
    required String difficulty,
    required Color accentColor,
    required VoidCallback onStart,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative patterns
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.08),
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
                      color: accentColor.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 30,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.05),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with gradient background
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withOpacity(0.2),
                              accentColor.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(
                            Icons.access_time_outlined,
                            estimatedTime,
                            accentColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorTheme.textLight,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFFBF0), // Putih tulang
                                foregroundColor: ColorTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
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
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor,
                                    accentColor.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    left: 20,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: onStart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Mulai Tes',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorTheme.accent.withOpacity(0.3),
                            ColorTheme.accent.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: ColorTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pengingat Assessment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Aktifkan notifikasi untuk mendapatkan pengingat',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textLight,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorTheme.textLight.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _assessments.map((assessment) {
                          bool isEnabled = _enabledNotifications.contains(assessment.title);
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: assessment != _assessments.last
                                    ? BorderSide(color: ColorTheme.textLight.withOpacity(0.2))
                                    : BorderSide.none,
                              ),
                            ),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              title: Text(
                                assessment.shortTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorTheme.textDark,
                                ),
                              ),
                              subtitle: Text(
                                assessment.estimatedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorTheme.textLight,
                                ),
                              ),
                              value: isEnabled,
                              activeColor: ColorTheme.primary,
                              onChanged: (bool value) {
                                setDialogState(() {
                                  if (value) {
                                    _enabledNotifications.add(assessment.title);
                                  } else {
                                    _enabledNotifications.remove(assessment.title);
                                  }
                                });
                                setState(() {});
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? 'Notifikasi ${assessment.shortTitle} diaktifkan'
                                          : 'Notifikasi ${assessment.shortTitle} dinonaktifkan',
                                    ),
                                    backgroundColor: ColorTheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                              ColorTheme.primaryLight,
                              ColorTheme.primary,
                              ColorTheme.primaryDark,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative pattern
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
                              left: 30,
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 15,
                              left: -5,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                            // Button
                            ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Center(
                            child: Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}