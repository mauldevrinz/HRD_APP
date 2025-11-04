import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'package:app/utils/test_result_storage.dart';
import 'admin/admin_dashboard_page.dart';
import 'package:app/services/auth_service.dart';
import 'auth/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  bool _notificationsEnabled = true;
  bool _assessmentReminders = true;
  bool _reportUpdates = true;
  bool _systemNotifications = false;
  
  int _totalTests = 0;
  int _completedTests = 0;
  
  // Cache controllers to avoid recreation
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final List<TextEditingController> _passwordControllers;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTestStats();
  }
  
  Future<void> _loadTestStats() async {
    try {
      final results = await TestResultStorage.getTestResults();
      setState(() {
        _totalTests = results.length;
        _completedTests = results.where((r) => r['status'] == 'Selesai').length;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _initializeControllers() {
    final userProfile = context.read<UserProfileProvider>().userProfile;
    _nameController = TextEditingController(text: userProfile?.name ?? '');
    _emailController = TextEditingController(text: userProfile?.email ?? '');
    _passwordControllers = List.generate(3, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    for (final controller in _passwordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        final userProfile = userProfileProvider.userProfile;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with gradient
                  Container(
                    width: double.infinity,
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
                        // Decorative pattern
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
                          top: 80,
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
                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Icon di kiri
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: const Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text di kanan
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Halo, ${(userProfile?.name ?? 'User').split(' ').first}!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kelola profil dan pengaturan Anda',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
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

                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                      
                      // Profile Card - Enhanced with stats
                      if (userProfile != null)
                        Hero(
                          tag: 'profile-card',
                          child: _buildEnhancedProfileCard(userProfile, userProfileProvider),
                        ),

                      const SizedBox(height: 32),

                      // Admin Dashboard Button (only for admin)
                      if (userProfile?.role == 'admin') ...[
                        _buildSection(
                          title: 'Admin Panel',
                          children: [
                            _buildOptimizedMenuItem(
                              icon: Icons.dashboard_outlined,
                              title: 'Dashboard Admin',
                              subtitle: 'Lihat statistik dan KPI',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminDashboardPage(),
                                  ),
                                );
                              },
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primaryColorLight, AppColors.primaryColor],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Account Settings Section
                      _buildSection(
                        title: 'Pengaturan Akun',
                        children: [
                          _buildOptimizedMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profil',
                            subtitle: 'Ubah nama dan informasi pribadi',
                            onTap: () => _showEditProfileDialog(context, userProfileProvider),
                          ),
                          _buildDivider(),
                          _buildOptimizedMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Ubah Password',
                            subtitle: 'Perbarui kata sandi akun Anda',
                            onTap: _showChangePasswordDialog,
                          ),
                          _buildDivider(),
                          _buildOptimizedMenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifikasi',
                            subtitle: _getNotificationSubtitle(),
                            onTap: _showNotificationSettingsDialog,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _notificationsEnabled 
                                    ? AppColors.primaryColor.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _notificationsEnabled ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  color: _notificationsEnabled 
                                      ? AppColors.primaryColor 
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Support Section
                      _buildSection(
                        title: 'Bantuan & Dukungan',
                        children: [
                          _buildOptimizedMenuItem(
                            icon: Icons.help_outline,
                            title: 'Pusat Bantuan',
                            subtitle: 'FAQ, panduan, dan tips',
                            onTap: _showHelpDialog,
                          ),
                          _buildDivider(),
                          _buildOptimizedMenuItem(
                            icon: Icons.feedback_outlined,
                            title: 'Beri Feedback',
                            subtitle: 'Bagikan saran dan masukan',
                            onTap: _showFeedbackDialog,
                          ),
                          _buildDivider(),
                          _buildOptimizedMenuItem(
                            icon: Icons.info_outline,
                            title: 'Tentang Aplikasi',
                            subtitle: 'Versi 1.0.0 - November 2024',
                            onTap: _showAboutDialog,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Logout Section
                      _buildSection(
                        title: 'Aksi',
                        children: [
                          _buildOptimizedMenuItem(
                            icon: Icons.logout,
                            title: 'Keluar',
                            subtitle: 'Keluar dari akun Anda',
                            onTap: _showLogoutDialog,
                            color: Colors.red,
                            showArrow: false,
                          ),
                        ],
                      ),

                        const SizedBox(height: 40),
                      ],
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

  // Enhanced Profile Card with stats
  Widget _buildEnhancedProfileCard(UserProfile userProfile, UserProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image with edit button
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: userProfile.photoUrl != null
                      ? NetworkImage(userProfile.photoUrl!)
                      : null,
                  child: userProfile.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 45,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _showImagePickerDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // User Info
          Text(
            userProfile.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            userProfile.email,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Bergabung sejak November 2024',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Tes Selesai', '$_completedTests', Icons.check_circle_outline),
                _buildStatDivider(),
                _buildStatItem('Laporan', '$_totalTests', Icons.description_outlined),
                _buildStatDivider(),
                _buildStatItem('Level', 'Aktif', Icons.trending_up),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  // Optimized Section Builder
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Enhanced Menu Item with better UX
  Widget _buildOptimizedMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: color ?? AppColors.primaryColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color ?? AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Trailing widget
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ] else if (showArrow) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Utility Methods
  String _getNotificationSubtitle() {
    int activeCount = 0;
    if (_assessmentReminders) activeCount++;
    if (_reportUpdates) activeCount++;
    if (_systemNotifications) activeCount++;
    
    if (!_notificationsEnabled) return 'Semua notifikasi dinonaktifkan';
    return '$activeCount dari 3 notifikasi aktif';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Dialog Methods (Optimized)
  void _showEditProfileDialog(BuildContext context, UserProfileProvider provider) {
    _nameController.text = provider.userProfile?.name ?? '';
    _emailController.text = provider.userProfile?.email ?? '';

    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.person_outline,
        title: 'Edit Profil',
        children: [
          _buildTextField(_nameController, 'Nama Lengkap', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Email', Icons.email),
          const SizedBox(height: 8),
          Text(
            'Email akan digunakan untuk login dan notifikasi',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildDialogActions(
            onCancel: () => Navigator.pop(context),
            onSave: () async {
              if (_nameController.text.trim().isEmpty) {
                _showSnackBar('Nama tidak boleh kosong', isError: true);
                return;
              }
              
              if (!_emailController.text.contains('@')) {
                _showSnackBar('Format email tidak valid', isError: true);
                return;
              }
              
              provider.updateProfile(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
              );
              Navigator.pop(context);
              _showSnackBar('Profil berhasil diperbarui');
            },
            saveText: 'Simpan',
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    for (final controller in _passwordControllers) {
      controller.clear();
    }

    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.lock_outline,
        title: 'Ubah Password',
        children: [
          _buildTextField(_passwordControllers[0], 'Password Saat Ini', Icons.lock, obscure: true),
          const SizedBox(height: 16),
          _buildTextField(_passwordControllers[1], 'Password Baru', Icons.lock_open, obscure: true),
          const SizedBox(height: 16),
          _buildTextField(_passwordControllers[2], 'Konfirmasi Password', Icons.lock_reset, obscure: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syarat Password:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Minimal 8 karakter\n• Kombinasi huruf dan angka\n• Setidaknya 1 huruf besar',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDialogActions(
            onCancel: () => Navigator.pop(context),
            onSave: () {
              if (_passwordControllers[1].text.length < 8) {
                _showSnackBar('Password minimal 8 karakter', isError: true);
                return;
              }
              if (_passwordControllers[1].text != _passwordControllers[2].text) {
                _showSnackBar('Konfirmasi password tidak sesuai', isError: true);
                return;
              }
              
              Navigator.pop(context);
              _showSnackBar('Password berhasil diubah');
            },
            saveText: 'Ubah Password',
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _buildOptimizedDialog(
            icon: Icons.notifications_outlined,
            title: 'Pengaturan Notifikasi',
            children: [
              _buildNotificationTile(
                'Pengingat Assessment',
                'Dapatkan notifikasi untuk tes yang akan datang',
                _assessmentReminders,
                (value) => setDialogState(() {
                  _assessmentReminders = value;
                  setState(() {});
                }),
              ),
              _buildNotificationTile(
                'Update Laporan',
                'Dapatkan notifikasi ketika laporan Anda diperbarui',
                _reportUpdates,
                (value) => setDialogState(() {
                  _reportUpdates = value;
                  setState(() {});
                }),
              ),
              _buildNotificationTile(
                'Notifikasi Sistem',
                'Informasi pemeliharaan dan pembaruan sistem',
                _systemNotifications,
                (value) => setDialogState(() {
                  _systemNotifications = value;
                  setState(() {});
                }),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pengaturan akan disimpan secara otomatis',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildGradientButton(
                text: 'Selesai',
                onPressed: () {
                  _notificationsEnabled = _assessmentReminders || _reportUpdates || _systemNotifications;
                  Navigator.pop(context);
                  _showSnackBar('Pengaturan notifikasi disimpan');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.feedback_outlined,
        title: 'Beri Feedback',
        children: [
          Text(
            'Bagikan pengalaman dan saran Anda untuk meningkatkan aplikasi ini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tulis feedback Anda di sini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                'Berikan rating:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) => GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          _buildDialogActions(
            onCancel: () => Navigator.pop(context),
            onSave: () {
              Navigator.pop(context);
              _showSnackBar('Terima kasih atas feedback Anda!');
            },
            saveText: 'Kirim',
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final List<Map<String, dynamic>> helpItems = [
      {
        'title': 'Panduan Pengguna',
        'icon': Icons.book_outlined,
        'subtitle': 'Cara menggunakan aplikasi',
      },
      {
        'title': 'FAQ',
        'icon': Icons.help_outline,
        'subtitle': 'Pertanyaan yang sering diajukan',
      },
      {
        'title': 'Video Tutorial',
        'icon': Icons.play_circle_outline,
        'subtitle': 'Tutorial step-by-step',
      },
      {
        'title': 'Kontak Support',
        'icon': Icons.support_agent,
        'subtitle': 'Hubungi tim dukungan',
      },
      {
        'title': 'Lapor Masalah',
        'icon': Icons.bug_report_outlined,
        'subtitle': 'Laporkan bug atau masalah',
      },
      {
        'title': 'Komunitas',
        'icon': Icons.forum_outlined,
        'subtitle': 'Bergabung dengan komunitas pengguna',
      },
    ];

    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.help_outline,
        title: 'Pusat Bantuan',
        children: [
          Text(
            'Pilih topik bantuan yang Anda butuhkan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: helpItems.map((item) => _buildHelpTile(
                  item['title'] as String,
                  item['icon'] as IconData,
                  item['subtitle'] as String,
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            text: 'Tutup',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.info_outline,
        title: 'Tentang Aplikasi',
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assessment,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Assessment App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0 (Build 100)',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aplikasi assessment yang membantu Anda melakukan berbagai tes kesehatan dan psikologi dengan mudah dan akurat.',
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Tanggal Rilis', 'November 2024'),
          _buildInfoRow('Platform', 'Android, iOS, Web'),
          _buildInfoRow('Ukuran App', '15.2 MB'),
          _buildInfoRow('Rating', '4.8 ⭐ (1,234 ulasan)'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Dikembangkan dengan ❤️ oleh',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'mauldevrinz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Software Developer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Membuka lisensi...');
                  },
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Lisensi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGradientButton(
                  text: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.logout,
        title: 'Keluar dari Akun',
        iconColor: Colors.red,
        children: [
          Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anda perlu login kembali untuk mengakses aplikasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                    alignment: Alignment.center,
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Implement actual logout logic
                        await AuthService().signOut();
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Center(
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildOptimizedDialog(
        icon: Icons.camera_alt_outlined,
        title: 'Ubah Foto Profil',
        children: [
          Text(
            'Pilih sumber foto profil Anda',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Membuka kamera...');
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Membuka galeri...');
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Reusable Widget Components
  Widget _buildOptimizedDialog({
    required IconData icon,
    required String title,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildDialogActions({
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required String saveText,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
              alignment: Alignment.center,
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(text: saveText, onPressed: onSave),
        ),
      ],
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed}) {
    return Container(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                alignment: Alignment.center,
              ),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
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
    );
  }

  Widget _buildHelpTile(String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pop(context);
          _showSnackBar('Membuka $title...');
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        dense: true,
      ),
    );
  }
}