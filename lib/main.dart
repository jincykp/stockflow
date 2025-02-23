import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/views/screens/login_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stockflow/views/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            debugPrint('🏭 Creating ProductProvider');
            final provider = ProductProvider();
            // Initialize with current user
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              debugPrint('👤 Found user: ${user.uid}');
              provider.initialize(user.uid);
            } else {
              debugPrint('⚠️ No authenticated user found');
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
