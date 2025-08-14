import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/habits_main_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/level_screen.dart';
import 'package:personal_rise_daily_growth_336t/pages/settings_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
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
  final _pages = const [
    LevelScreen(),
    HabitsMainPage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  late final PageController _pc;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    if (index == _current) return;
    await _pc.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _current = i),
              children: _pages,
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 68.w, vertical: 48.h),
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLevel2,
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .05),
                    width: 1.w,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final count = _items.length;
                    final bubble = 56.w;
                    final totalW = c.maxWidth;

                    final spacing = (totalW - count * bubble) / (count + 1);
                    final top = (56.h - bubble) / 2;
                    final left = spacing * (_current + 1) + bubble * _current;

                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.ease,
                          top: top,
                          left: left,
                          width: bubble,
                          height: bubble,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_items.length, (i) {
                            final item = _items[i];
                            final selected = i == _current;

                            return GestureDetector(
                              onTap: () => _goTo(i),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: 56.w,
                                height: 56.w,
                                child: Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutBack,
                                    scale: 1,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (!selected)
                                          Container(
                                            width: 56.w,
                                            height: 56.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.03,
                                              ),
                                            ),
                                          ),

                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          child: Image.asset(
                                            selected
                                                ? item.activeAsset
                                                : item.asset,
                                            key: ValueKey<bool>(selected),
                                            width: 28.w,
                                            height: 28.w,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
