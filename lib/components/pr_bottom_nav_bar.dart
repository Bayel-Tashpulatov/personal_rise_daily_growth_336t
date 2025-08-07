import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class _NavItem {
  const _NavItem(this.asset, this.activeAsset);
  final String asset;
  final String activeAsset;
}

const _items = <_NavItem>[
  _NavItem('assets/nav/levels.png', 'assets/nav/levels_active.png'),
  _NavItem('assets/nav/habbits.png', 'assets/nav/habbits_active.png'),
  _NavItem('assets/nav/statistics.png', 'assets/nav/statistics_active.png'),
  _NavItem('assets/nav/settings.png', 'assets/nav/settings_active.png'),
];

class PrBottomNavBar extends StatefulWidget {
  const PrBottomNavBar({super.key});

  @override
  State<PrBottomNavBar> createState() => _PrBottomNavBarState();
}

class _PrBottomNavBarState extends State<PrBottomNavBar> {
  int _current = 0;

  static const _pages = [
    TestPage(title: 'Levels'),
    TestPage(title: 'Habbits'),
    TestPage(title: 'Statistics'),
    TestPage(title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _pages[_current],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 68.w, vertical: 48.h),
              child: Container(
                height: 64.h,
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .05),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_items.length, (i) {
                    final item = _items[i];
                    final selected = i == _current;

                    return GestureDetector(
                      onTap: () => setState(() => _current = i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primaryAccent
                              : Colors.white.withValues(alpha: 0.03),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          selected ? item.activeAsset : item.asset,
                          width: 28.w,
                          height: 28.w,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: TextStyle(fontSize: 42.sp)),
      ),
    );
  }
}
