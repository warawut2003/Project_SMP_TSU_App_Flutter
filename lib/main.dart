import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/pages/HomePage.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:project_smp_tsu_application/provider/project_provider.dart';
import 'package:project_smp_tsu_application/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:project_smp_tsu_application/pages/User/registerProject.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
     providers: [
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => ProjectProvider()), // Add ProjectProvider
        ChangeNotifierProvider(create: (context) => UserProviders()),
      ],
        child: MaterialApp(
          title: 'HomePage',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home:  HomePage(),
        ),
      );
  }
}
