// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart'; // Untuk akses `supabase`
import '../../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Tunggu frame pertama selesai render sebelum navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    // Tunggu sedikit untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 1));

    // `mounted` check
    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session != null) {
      Get.offAllNamed(AppRoutes.profile);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}
