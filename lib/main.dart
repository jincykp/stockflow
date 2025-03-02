import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/repositories/sales_repositories.dart';
import 'package:stockflow/services/auth_state_manager.dart';
import 'package:stockflow/viewmodel/customer_provider.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/viewmodel/sales_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stockflow/viewmodel/user_provider.dart';
import 'package:stockflow/views/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  syncAuthState();
  runApp(const MyApp()); // Add this to your main.dart or app initialization
}

void syncAuthState() async {
  // Check Firebase auth state
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // User is logged in with Firebase, update SharedPreferences
    await AuthStateManager.setLoggedIn();
    print("Auth state synced: User is logged in");
  } else {
    // User is not logged in with Firebase, update SharedPreferences
    await AuthStateManager.setLoggedOut();
    print("Auth state synced: User is logged out");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = ProductProvider();
            // Initialize with current user
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              debugPrint('Found user: ${user.uid}');
              provider.initialize(user.uid);
            } else {
              debugPrint(' No authenticated user found');
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(SalesRepository()),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
