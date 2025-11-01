import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        final userProfile = userProfileProvider.userProfile;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // === PROFILE CARD ===
              _buildProfileCard(userProfile),

              const SizedBox(height: 24),

              // === ACCOUNT SETTINGS ===
              _buildSectionHeader('Account Settings'),
              _buildMenuItem(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(context, userProfileProvider),
              ),
              _buildMenuItem(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildMenuItem(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () => _showNotificationSettingsDialog(context),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                    _showSnackBar(
                      notificationsEnabled
                          ? 'Notifikasi diaktifkan'
                          : 'Notifikasi dinonaktifkan',
                    );
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              // === PREFERENCES ===
              _buildSectionHeader('Preferences'),
              _buildMenuItem(
                icon: Icons.language,
                title: 'Language',
                onTap: () => _showLanguageDialog(context),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedLanguage,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              _buildMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () => _showHelpDialog(context),
              ),

              const SizedBox(height: 24),

              // === LOGOUT ===
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _showLogoutDialog(context),
                color: Colors.red,
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // === WIDGET BUILDERS ===
  Widget _buildProfileCard(UserProfile userProfile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: userProfile.photoUrl != null
                    ? NetworkImage(userProfile.photoUrl!)
                    : null,
                child: userProfile.photoUrl == null
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 60,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            userProfile.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color ?? AppColors.primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: color ?? AppColors.textColor,
          ),
        ),
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // === DIALOGS ===
  void _showEditProfileDialog(BuildContext context, UserProfileProvider provider) {
    final nameController = TextEditingController(text: provider.userProfile.name);
    final emailController = TextEditingController(text: provider.userProfile.email);

    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        icon: Icons.person,
        title: 'Edit Profile',
        children: [
          _buildTextField(nameController, 'Nama'),
          const SizedBox(height: 16),
          _buildTextField(emailController, 'Email'),
          const SizedBox(height: 24),
          _buildDialogActions(
            onCancel: () => Navigator.pop(context),
            onSave: () {
              provider.updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
              Navigator.pop(context);
              _showSnackBar('Profile berhasil diperbarui');
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controllers = List.generate(3, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        icon: Icons.lock,
        title: 'Change Password',
        children: [
          _buildTextField(controllers[0], 'Password Saat Ini', obscure: true),
          const SizedBox(height: 16),
          _buildTextField(controllers[1], 'Password Baru', obscure: true),
          const SizedBox(height: 16),
          _buildTextField(controllers[2], 'Konfirmasi Password Baru', obscure: true),
          const SizedBox(height: 24),
          _buildDialogActions(
            onCancel: () => Navigator.pop(context),
            onSave: () {
              Navigator.pop(context);
              _showSnackBar('Password berhasil diubah');
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _buildDialog(
            icon: Icons.notifications,
            title: 'Notification Settings',
            children: [
              SwitchListTile(
                title: const Text('Assessment Reminders'),
                subtitle: const Text('Get notified about upcoming assessments'),
                value: notificationsEnabled,
                onChanged: (v) {
                  setDialogState(() => notificationsEnabled = v);
                  setState(() {});
                },
                activeColor: AppColors.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Report Updates'),
                subtitle: const Text('Get notified when your reports are updated'),
                value: true,
                onChanged: null,
                activeColor: AppColors.primaryColor,
              ),
              SwitchListTile(
                title: const Text('System Notifications'),
                subtitle: const Text('Get notified about system updates and maintenance'),
                value: false,
                onChanged: null,
                activeColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 24),
              _buildGradientButton(
                text: 'Simpan',
                onPressed: () {
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

  void _showLanguageDialog(BuildContext context) {
    final languages = ['Indonesia', 'English', '中文', 'Español'];
    String tempLang = selectedLanguage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return _buildDialog(
            icon: Icons.language,
            title: 'Select Language',
            children: [
              ...languages.map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: tempLang,
                    onChanged: (v) {
                      setDialogState(() => tempLang = v!);
                    },
                    activeColor: AppColors.primaryColor,
                  )),
              const SizedBox(height: 24),
              _buildDialogActions(
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  setState(() => selectedLanguage = tempLang);
                  Navigator.pop(context);
                  _showSnackBar('Bahasa diubah ke $selectedLanguage');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        icon: Icons.help,
        title: 'Help & Support',
        children: [
          const Text(
            'How can we help you today?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildHelpTile('User Guide', Icons.book, 'Membuka panduan pengguna...'),
          _buildHelpTile('FAQ', Icons.question_answer, 'Membuka FAQ...'),
          _buildHelpTile('Contact Support', Icons.contact_support, 'Membuka halaman dukungan...'),
          const SizedBox(height: 24),
          _buildGradientButton(
            text: 'Tutup',
            onPressed: () => Navigator.pop(context),
            gradient: const LinearGradient(colors: [Colors.grey, Colors.grey]),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        icon: Icons.logout,
        title: 'Logout',
        iconColor: Colors.red,
        children: [
          const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGradientButton(
                  text: 'Keluar',
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Anda telah keluar dari akun');
                  },
                  gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === REUSABLE DIALOG COMPONENTS ===
  Widget _buildDialog({
    required IconData icon,
    required String title,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: iconColor ?? AppColors.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDialogActions({required VoidCallback onCancel, required VoidCallback onSave}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildGradientButton(text: 'Simpan', onPressed: onSave)),
      ],
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed, LinearGradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColorLight, AppColors.primaryColor, AppColors.accentColor],
              stops: [0.0, 0.2, 1.0],
            ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildHelpTile(String title, IconData icon, String snackbarText) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showSnackBar(snackbarText);
      },
    );
  }
}