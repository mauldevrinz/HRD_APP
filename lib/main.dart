import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;
import 'pages/user_profile_provider.dart';
import 'pages/home_page.dart';
import 'pages/report_page.dart';
import 'pages/account_page.dart';
import 'pages/auth/splash_screen.dart';
import 'pages/admin/admin_home_page.dart';
import 'pages/admin/admin_report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  try {
    if (kIsWeb) {
      // Web platform
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
      print('✅ Firebase initialized for Web');
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized for ${Platform.operatingSystem}');
    } else {
      print('⚠️ Firebase not supported on this platform (${Platform.operatingSystem})');
      print('⚠️ Running in development mode without Firebase');
    }
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('⚠️ Running in development mode without Firebase');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProfileProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assessment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load user profile when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile();
    });
  }

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
        
        final List<Widget> pages = isAdmin 
            ? [
                const AdminHomePage(),
                const AdminReportPage(),
                const AccountPage(),
              ]
            : [
                const HomePage(),
                const ReportPage(),
                const AccountPage(),
              ];

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
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.textColor.withOpacity(0.5),
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: isAdmin ? 'Dashboard' : 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assessment),
                  label: isAdmin ? 'Laporan' : 'Report',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}