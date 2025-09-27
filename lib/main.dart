import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:k2b2_video/firebase_options.dart';
import 'package:media_kit/media_kit.dart';

import 'core/di.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'models/download_models.dart';
import 'screens/downloads_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/video_screen.dart';
import 'services/shorebird_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit for youtube_shorts
  MediaKit.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DownloadTaskAdapter());
  Hive.registerAdapter(DownloadSettingsAdapter());
  Hive.registerAdapter(DownloadStatusAdapter());
  Hive.registerAdapter(DownloadQualityAdapter());

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Initialize dependency injection
  await init();

  // Initialize Shorebird update checking
  ShorebirdUpdateService.initializeUpdateChecking();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>())],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // Start with Home Screen
  final List<Widget> _screens = const [
    SplashScreen(),
    LoginScreen(),
    HomeScreen(),
    VideoScreen(),
    DownloadsScreen(),
    SubscriptionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Splash'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Subscribe'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
