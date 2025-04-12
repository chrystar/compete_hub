import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/firebase_options.dart';
import 'package:compete_hub/providers/auth_provider.dart';
import 'package:compete_hub/src/providers/event_provider.dart';
import 'package:compete_hub/src/auth/sign_up.dart';
import 'package:compete_hub/src/providers/news_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProviders(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(),
        ),
    
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: lightTheme,
        themeMode: ThemeMode.light,
        home: SignUpScreen(),
      ),
    );
  }
}
