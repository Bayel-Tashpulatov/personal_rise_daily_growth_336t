import 'package:flutter/material.dart';
import 'package:personal_rise_daily_growth_336t/widgets/pr_bottom_nav_bar.dart';

class PrSplashScreen extends StatefulWidget {
  const PrSplashScreen({super.key});
  @override
  State<PrSplashScreen> createState() => _PrSplashScreenState();
}

class _PrSplashScreenState extends State<PrSplashScreen> {
  static const _minShow = Duration(seconds: 2);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _start();
  }

  Future<void> _start() async {
    await Future.wait([
      precacheImage(
        const AssetImage('assets/images/splash_background.png'),
        context,
      ),
      Future.delayed(_minShow),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PrBottomNavBar(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_background.png',
            fit: BoxFit.cover,
            errorBuilder: (_, e, st) {
              debugPrint('Splash image error: $e');
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
