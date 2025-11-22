# Health Assessment & Wellness App

A comprehensive Flutter application for health assessment, wellness testing, and personal health analytics. This app includes multiple psychological tests (BMI, Big Five personality, burnout assessment), real-time reporting, admin dashboard, and cloud-based data management using Firebase.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Usage Guide](#usage-guide)
- [Features Explanation](#features-explanation)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## ✨ Features

### User Features
- **🔐 Authentication**: Secure login and registration with Firebase
- **🧬 Big Five Personality Test**: Comprehensive 50-question personality assessment
- **⚖️ BMI Calculator**: Body Mass Index calculation with health insights
- **😰 Burnout Assessment**: Professional burnout level evaluation
- **📊 Personal Reports**: Detailed health and psychological reports with PDF export
- **👤 User Profile**: Manage personal information and settings
- **📱 Multi-Platform**: Works on Android, iOS, Web, Linux, macOS, and Windows

### Admin Features
- **📈 Analytics Dashboard**: Real-time charts and statistics
- **👥 User Management**: View and manage all users
- **📑 Report Management**: Access and analyze user reports
- **📊 Data Visualization**: Charts showing test results distribution

---

## 🛠️ Prerequisites

Before you start, ensure you have the following installed:

- **Flutter SDK** (>=2.17.0, <3.0.0) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart** (included with Flutter)
- **Firebase Account** - [Create Firebase Project](https://firebase.google.com/)
- **Git** (for version control)
- **Android Studio** or **Xcode** (for mobile development)

### System Requirements
- **RAM**: Minimum 4GB
- **Storage**: Minimum 5GB free space
- **Node.js** (optional, for web deployment)

---

## 📦 Installation

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd app
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This command will download and install all required packages defined in `pubspec.yaml`.

### Step 3: Verify Installation

```bash
flutter doctor
```

This will check your Flutter installation and report any missing dependencies.

### Step 4: (Optional) Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create a Firestore database
5. Enable Firebase Storage
6. Download configuration files for your platforms

---

## ⚙️ Configuration

### Firebase Setup

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in: `android/app/google-services.json`
3. Ensure `google-services.json` is referenced in `android/app/build.gradle`

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to Xcode project in `ios/Runner/`

#### For Web:
1. Update `lib/firebase_options.dart` with your Firebase web config
2. Configuration is already set up in the file

### Environment Setup

```bash
# Set Flutter to the desired channel
flutter channel stable
flutter upgrade

# Enable platform-specific features
flutter config --enable-web          # Enable web support
flutter config --enable-windows      # Enable Windows support
flutter config --enable-linux        # Enable Linux support
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point and Firebase initialization
├── firebase_options.dart              # Firebase configuration
├── pages/
│   ├── auth/
│   │   ├── login_page.dart           # Login screen
│   │   ├── register_page.dart        # Registration screen
│   │   └── splash_screen.dart        # Initial splash screen
│   ├── home_page.dart                # Main home screen
│   ├── bigfive_test_page.dart        # Big Five personality test
│   ├── bmi_test_page.dart            # BMI calculation page
│   ├── burnout_test_page.dart        # Burnout assessment page
│   ├── report_page.dart              # User reports and PDF export
│   ├── account_page.dart             # User account settings
│   ├── user_profile_provider.dart    # User data state management
│   └── admin/
│       ├── admin_home_page.dart      # Admin dashboard home
│       ├── admin_dashboard_page.dart # Analytics and statistics
│       └── admin_report_page.dart    # Admin report viewer
├── services/
│   ├── auth_service.dart             # Firebase authentication
│   └── test_progress_service.dart    # Test progress tracking
├── widgets/
│   └── profile_avatar.dart           # Reusable profile avatar widget
├── utils/
│   ├── colors.dart                   # App color scheme
│   ├── create_admin.dart             # Admin user creation utility
│   └── fix_admin_document.dart       # Admin document fixes
└── test/                              # Unit and widget tests
```

---

## 📖 Usage Guide

### 1️⃣ Starting the App

#### Run on Android Device/Emulator:
```bash
flutter run -d android
```

#### Run on iOS Device/Simulator:
```bash
flutter run -d ios
```

#### Run on Web Browser:
```bash
flutter run -d web
```

#### Run on Desktop (Windows/Linux/macOS):
```bash
# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos
```

#### Run on Specific Device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### 2️⃣ First Time Setup

1. **Launch the App** → You'll see the Splash Screen
2. **Create Account** → Tap "Register" and enter your details
3. **Email & Password** → Complete the registration
4. **Login** → Use your credentials to log in
5. **Fill Profile** → Complete your personal information
6. **Take Tests** → Start with any available assessment

---

## 🎯 Features Explanation

### 🧬 Big Five Personality Test

**What is it?**: A 50-question psychological test measuring five personality dimensions.

**How to Use**:
1. Navigate to "Home" → "Big Five Test"
2. Answer each question on a scale of 1-5
3. Submit when complete
4. View results showing your personality traits
5. Download report as PDF

**Results Include**:
- Openness
- Conscientiousness
- Extraversion
- Agreeableness
- Neuroticism

### ⚖️ BMI Calculator

**What is it?**: Calculates Body Mass Index based on height and weight.

**How to Use**:
1. Go to "Home" → "BMI Test"
2. Enter your height (in cm)
3. Enter your weight (in kg)
4. View instant BMI calculation
5. See health recommendations
6. Save and track history

**Health Categories**:
- Underweight: BMI < 18.5
- Normal Weight: BMI 18.5 - 24.9
- Overweight: BMI 25 - 29.9
- Obese: BMI ≥ 30

### 😰 Burnout Assessment

**What is it?**: Measures job burnout and stress levels using 22 questions.

**How to Use**:
1. Navigate to "Home" → "Burnout Test"
2. Answer questions about work-related stress
3. Scale: 0 (Never) to 6 (Every day)
4. Submit responses
5. Get burnout score and recommendations

**Burnout Levels**:
- Low: Score 0-20
- Moderate: Score 21-40
- High: Score 41-60
- Critical: Score 61+

### 📊 Reports & Analytics

**Viewing Reports**:
1. Tap "Reports" in main menu
2. Select a test from the list
3. View detailed results with charts
4. Tap "Download PDF" to export report

**Report Contents**:
- Test date and time
- Overall score and interpretation
- Detailed breakdown of results
- Visual charts and graphs
- Personalized recommendations

### 👤 User Profile

**Manage Your Account**:
1. Tap "Account" in main menu
2. View and edit personal information
3. Change password
4. View test history
5. Manage privacy settings
6. Log out

### 🔐 Admin Dashboard (Admin Users Only)

**Accessing Admin Panel**:
- Admin users see additional menu option
- Tap "Admin Dashboard"

**Admin Features**:
1. **Dashboard**: View key statistics and charts
2. **Users**: Browse all registered users
3. **Reports**: View aggregated reports
4. **Analytics**: Analyze test result distributions

---

## 🐛 Troubleshooting

### Issue: Firebase Not Initializing

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Check Firebase setup**:
- Verify `google-services.json` (Android) is in correct location
- Check `GoogleService-Info.plist` (iOS) is added to Xcode
- Confirm Firebase project is active

### Issue: "No devices found"

**Solution**:
```bash
# List available devices
flutter devices

# If no devices, create an emulator:
# For Android: Open Android Studio → Device Manager → Create Virtual Device
# For iOS: Open Xcode → Window → Devices and Simulators → Create Simulator
```

### Issue: Build Fails on iOS

**Solution**:
```bash
# Clean iOS build
cd ios
rm -rf Pods Podfile.lock .symlinks/
cd ..
flutter clean
flutter pub get
flutter run -d ios
```

### Issue: Web App Doesn't Load

**Solution**:
```bash
# Clean web build
flutter clean
flutter pub get
flutter run -d web --web-renderer html
```

### Issue: Can't Login to App

**Checklist**:
- ✅ Firebase Authentication is enabled
- ✅ Email/Password provider is active in Firebase
- ✅ User account is created in Firebase Auth
- ✅ Email is verified (if required)
- ✅ Internet connection is active

### Issue: Test Results Not Saving

**Solution**:
```bash
# Verify Firestore setup:
1. Firebase Console → Firestore Database
2. Create "users" collection
3. Ensure security rules allow write access
4. Check user has permission to write data
```

---

## 📲 Building for Production

### Android

```bash
# Create release build
flutter build apk --release

# Or for App Bundle (recommended for Play Store)
flutter build appbundle --release

# Located in: build/app/outputs/
```

### iOS

```bash
# Create release build
flutter build ios --release

# Build for distribution
flutter build ios --release --codesign

# Use Xcode to archive and submit to App Store
```

### Web

```bash
# Build for web
flutter build web --release

# Files in: build/web/
# Deploy to any web hosting service
```

### Windows/Linux

```bash
# Build for Windows
flutter build windows --release

# Build for Linux
flutter build linux --release

# Executables in: build/<platform>/release/
```

---

## 🔧 Development

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Analysis

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/
```

### Enable Debug Mode

```bash
flutter run -v  # Verbose output
flutter run --profile  # Profile mode
flutter run --release  # Release mode
```

---

## 📚 Dependencies

Key packages used in this project:

- **provider** (^6.0.0): State management
- **firebase_core** (^2.27.0): Firebase initialization
- **firebase_auth** (^4.17.8): Authentication
- **cloud_firestore** (^4.15.8): Database
- **firebase_storage** (^11.6.9): File storage
- **intl** (^0.18.1): Internationalization
- **pdf** (^3.10.7): PDF generation
- **printing** (^5.11.1): Print functionality
- **fl_chart** (^0.66.0): Chart visualization
- **image_picker** (^1.0.4): Image selection
- **cached_network_image** (^3.3.1): Image caching

---

## 🚀 Performance Tips

1. **Use Release Build**: Always test with `flutter run --release`
2. **Enable Proguard**: For Android, enable code shrinking
3. **Optimize Images**: Use appropriate image sizes
4. **Cache Data**: Use SharedPreferences for local caching
5. **Lazy Load**: Load data only when needed
6. **Profile App**: Use DevTools to identify bottlenecks

---

## 📞 Support

### Getting Help

- **Flutter Documentation**: https://flutter.dev/docs
- **Firebase Documentation**: https://firebase.google.com/docs
- **Stack Overflow**: Tag questions with `flutter`, `firebase`
- **GitHub Issues**: Report bugs in the repository

### Common Resources

- [Flutter Troubleshooting](https://flutter.dev/docs/testing/troubleshooting)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Packages](https://pub.dev/)
- [Material Design](https://material.io/design)

---

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Firebase for backend services
- All contributors and testers

---

**Last Updated**: November 2024

For the latest updates and issues, visit the project repository.
