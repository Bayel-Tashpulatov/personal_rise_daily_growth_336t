// pages/achievements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AchievementsCubit>();
    final list = _tab == 0 ? c.onTheWay : c.achieved;

    return Scaffold(
      backgroundColor: AppColors.backgroundLevel1,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLevel1,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', width: 44.w, height: 44.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ACHIEVEMENTS',
          style: TextStyle(
            color: AppColors.textlevel1,
            fontSize: 20.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.40,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _segBtn(
                        'On the Way',
                        _tab == 0,
                        () => setState(() => _tab = 0),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: _segBtn(
                        'Achieved',
                        _tab == 1,
                        () => setState(() => _tab = 1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ]),
            ),
          ),

          // список ачивок
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No Achievements Completed',
                  style: TextStyle(
                    color: AppColors.textlevel1,
                    fontSize: 15.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.30,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final a = list[i];
                  final active = a.achieved;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .1),
                        width: 1.w,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // картинка гарантированно влезает
                        SizedBox(
                          height: 72.h, // было 96.h — жирновато
                          child: Image.asset(
                            active
                                ? 'assets/images/cup_blue.png'
                                : 'assets/images/cup.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          a.def.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textlevel1,
                            fontSize: 11.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.22,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          a.def.desc,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textlevel2,
                            fontSize: 10.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.20,
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: list.length),

                // 👉 фиксируем высоту плитки, а не aspect ratio
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  mainAxisExtent: 160.h, // подгони 150–176.h под макет/шрифты
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _segBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 36.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryAccent : AppColors.backgroundLevel2,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textlevel1,
            fontSize: 15,
            fontFamily: 'SF Pro',
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.30,
          ),
        ),
      ),
    );
  }
}
