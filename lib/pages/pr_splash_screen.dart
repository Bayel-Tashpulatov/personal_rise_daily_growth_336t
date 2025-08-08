import 'package:flutter/material.dart';
import 'package:personal_rise_daily_growth_336t/widgets/pr_bottom_nav_bar.dart';

class PrSplashScreen extends StatefulWidget {
  const PrSplashScreen({super.key});

  @override
  State<PrSplashScreen> createState() => _PrSplashScreenState();
}

class _PrSplashScreenState extends State<PrSplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PrBottomNavBar()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
