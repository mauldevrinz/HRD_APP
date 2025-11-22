import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/report_page.dart';
import 'pages/account_page.dart';
import 'pages/admin/admin_home_page.dart';
import 'pages/admin/admin_report_page.dart';
import 'pages/user_profile_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // User pages
  static const List<Widget> _userPages = <Widget>[
    HomePage(),
    ReportPage(),
    AccountPage(),
  ];

  // Admin pages
  static const List<Widget> _adminPages = <Widget>[
    AdminHomePage(),
    AdminReportPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        final isAdmin = userProfileProvider.userProfile?.role == 'admin';
        final pages = isAdmin ? _adminPages : _userPages;

        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: isAdmin ? 'Dashboard' : 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assessment),
                  label: isAdmin ? 'Laporan' : 'Report',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle),
                  label: 'Account',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.textColor.withOpacity(0.5),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
            ),
          ),
        );
      },
    );
  }
}