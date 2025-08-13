// lib/features/statistics/presentation/widgets/top_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class TopSection extends StatefulWidget {
  final String title;
  final bool positive;
  final List<({Habit habit, int total})> items;
  final String periodLabel;
  const TopSection({
    super.key,
    required this.title,
    required this.positive,
    required this.items,
    this.periodLabel = 'For Last Month:',
  });

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.positive ? 'add_positive.png' : 'add_negative.png';
    final green = const Color(0xFF19D15C);
    final red = const Color(0xFFFF3B30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/icons/$icon', width: 18, height: 18),
            const SizedBox(width: 6),
            Text(
              widget.title,
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // ЕДИНАЯ карточка
        Container(
          height: 110.h,
          decoration: BoxDecoration(
            color: AppColors.backgroundLevel2,
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.items.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No data',
                      style: TextStyle(
                        color: AppColors.textlevel1.withOpacity(.7),
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // PageView ЛИСТАЕТСЯ ВНУТРИ КАРТОЧКИ
                    PageView.builder(
                      controller: _pc,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemCount: widget.items.length,
                      padEnds: false, // <— прижать контент к краям
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) => _TopHabitSlide(
                        data: widget.items[i],
                        periodLabel: widget.periodLabel,
                        positive: widget.positive,
                        green: green,
                        red: red,
                      ),
                    ),

                    // точки справа сверху
                    if (widget.items.length > 1)
                      Positioned(
                        right: 12.w,
                        top: 10.h,
                        child: Row(
                          children: List.generate(widget.items.length, (i) {
                            final active = i == _page;
                            return Container(
                              margin: EdgeInsets.only(left: 6.w),
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.textlevel1
                                    : AppColors.textlevel1.withOpacity(.25),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _TopHabitSlide extends StatelessWidget {
  const _TopHabitSlide({
    required this.data,
    required this.periodLabel,
    required this.positive,
    required this.green,
    required this.red,
  });

  final ({Habit habit, int total}) data;
  final String periodLabel;
  final bool positive;
  final Color green;
  final Color red;

  @override
  Widget build(BuildContext context) {
    final color = positive ? green : red;
    final sign = positive ? '+' : '-';

    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.habit.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Divider(height: 1, color: AppColors.textlevel1.withOpacity(.10)),
          SizedBox(height: 6.h),
          Text(
            data.habit.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: .2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                periodLabel,
                style: TextStyle(
                  color: AppColors.textlevel1.withOpacity(.7),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$sign\$${formatMoneyInt(data.total)}',
                style: TextStyle(
                  color: color,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
