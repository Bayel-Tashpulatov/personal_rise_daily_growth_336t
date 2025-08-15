import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class TopSection extends StatefulWidget {
  final String title;
  final bool positive;
  final List<({Habit habit, int total, String periodLabel})> items;
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

  double _cardHeight = 110.h;
  final Map<int, double> _heights = {};

  @override
  void initState() {
    super.initState();
    _pc = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.items.isNotEmpty) {
        final w = context.size?.width ?? MediaQuery.of(context).size.width;
        final h = _calcSlideHeight(context, widget.items[0], w);
        setState(() => _cardHeight = h);
        _heights[0] = h;
      }
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  double _calcSlideHeight(
    BuildContext context,
    ({Habit habit, int total, String periodLabel}) data,
    double cardWidth,
  ) {
    final horizontal = 12.w * 2;
    final vertical = 8.h * 2;

    final nameStyle = TextStyle(
      color: AppColors.textlevel1,
      fontSize: 16.sp,
      fontFamily: 'SF Pro',
      letterSpacing: 0.32,
      fontWeight: FontWeight.w900,
    );
    final descStyle = TextStyle(
      color: AppColors.textlevel1,
      fontSize: 15.sp,
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      letterSpacing: .30,
    );
    final periodStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.60),
      fontSize: 13.sp,
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      letterSpacing: 0.26,
    );
    final amountStyle = TextStyle(
      fontSize: 20.sp,
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w900,
      letterSpacing: 0.40,
    );

    double textWidth = cardWidth - horizontal;

    double measure(String text, TextStyle style, {int? maxLines}) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(maxWidth: textWidth);
      return tp.size.height;
    }

    final nameH = measure(data.habit.name, nameStyle, maxLines: 2);
    final dividerH = 1.h;
    final gap1 = 10.h;
    final gap2 = 8.h;
    final gap3 = 2.h;
    final descH = measure(data.habit.description, descStyle, maxLines: 5);

    final bottomRowH = math.max(
      measure('For Last Month:', periodStyle),
      measure('\$999999', amountStyle),
    );

    final contentH = nameH + gap1 + dividerH + gap2 + descH + gap3 + bottomRowH;
    final totalH = contentH + vertical;

    return totalH.clamp(110.h, 280.h);
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
            Image.asset('assets/icons/$icon', width: 24.w, height: 24.w),
            SizedBox(width: 8.w),
            Text(
              widget.title,
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 20.sp,
                fontFamily: 'SF Pro',
                letterSpacing: 0.40,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardW = constraints.maxWidth;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: _cardHeight,
              decoration: BoxDecoration(
                color: AppColors.backgroundLevel2,
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pc,
                    onPageChanged: (i) {
                      setState(() => _page = i);

                      final h =
                          _heights[i] ??
                          _calcSlideHeight(context, widget.items[i], cardW);
                      _heights[i] = h;
                      setState(() => _cardHeight = h);
                    },
                    itemCount: widget.items.length,
                    padEnds: false,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, i) => _TopHabitSlide(
                      data: widget.items[i],
                      positive: widget.positive,
                      green: green,
                      red: red,
                    ),
                  ),

                  if (widget.items.length > 1)
                    Positioned(
                      right: 12.w,
                      top: 8.h,
                      child: Row(
                        children: List.generate(widget.items.length, (i) {
                          final active = i == _page;
                          return Container(
                            margin: EdgeInsets.only(left: 8.w),
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primaryAccent
                                  : AppColors.primaryAccent.withValues(
                                      alpha: .3,
                                    ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TopHabitSlide extends StatelessWidget {
  const _TopHabitSlide({
    required this.data,
    required this.positive,
    required this.green,
    required this.red,
  });

  final ({Habit habit, int total, String periodLabel}) data;
  final bool positive;
  final Color green;
  final Color red;

  @override
  Widget build(BuildContext context) {
    final color = positive ? green : red;
    final sign = positive ? '+' : '-';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.habit.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 16.sp,
              fontFamily: 'SF Pro',
              letterSpacing: 0.32,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          Divider(height: 1.h, color: Colors.white.withValues(alpha: 0.10)),
          SizedBox(height: 8.h),
          Text(
            data.habit.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 15.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              letterSpacing: .30,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                data.periodLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 13.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                ),
              ),
              const Spacer(),
              Text(
                '$sign\$${formatMoneyInt(data.total)}',
                style: TextStyle(
                  color: color,
                  fontSize: 20.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
