import 'package:compete_hub/core/utils/theme.dart';
import 'package:compete_hub/firebase_options.dart';
import 'package:compete_hub/providers/auth_provider.dart';
import 'package:compete_hub/src/providers/event_provider.dart';
import 'package:compete_hub/src/providers/feedback_provider.dart';
import 'package:compete_hub/src/auth/sign_up.dart';
import 'package:compete_hub/src/providers/news_provider.dart';
import 'package:compete_hub/src/providers/payment_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:compete_hub/src/screens/main_home_screen/main_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash duration
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    setState(() {
      _showSplash = false;
      _showOnboarding = !onboardingComplete;
      _initialized = true;
    });
  }

  void _finishOnboarding() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        home: const SplashScreen(),
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
      );
    }
    if (_showOnboarding) {
      return MaterialApp(
        home: OnboardingScreen(onFinish: _finishOnboarding),
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProviders(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedbackProvider(),
        ),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Compete Hub',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SignUpScreen(),
        routes: {
          '/home': (context) => const MainHomeScreen(),
        },
      ),
    );
  }
}
