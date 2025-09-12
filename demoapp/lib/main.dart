import 'package:demoapp/pages/get_started.dart';
import 'package:demoapp/pages/report_list_page.dart';
import 'package:demoapp/pages/uploadImage.dart';
import 'package:demoapp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nivaran',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      navigatorKey: navigatorkey,
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStarted(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signup(),
        '/home': (context) => const UploadImagePage(),
        '/my-reports':(context)=> const MyReportsPage()
      },
    ),
  );
}
