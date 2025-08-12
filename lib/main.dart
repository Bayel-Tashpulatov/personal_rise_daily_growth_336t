import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/pages/pr_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Hive.initFlutter();

  Hive.registerAdapter(HabitKindAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitLogAdapter());

  await Hive.openBox<Habit>('habits');
  await Hive.openBox<HabitLog>('habit_logs');
  runApp(const PersonalRiseDailyGrowth());
}

class PersonalRiseDailyGrowth extends StatelessWidget {
  const PersonalRiseDailyGrowth({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LevelCubit()),
            BlocProvider(create: (_) => HabitsCubit()),
            BlocProvider(
              create: (ctx) => AchievementsCubit(
                ctx.read<LevelCubit>(),
                ctx.read<HabitsCubit>(),
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: const PrSplashScreen(),
          ),
        );
      },
    );
  }
}
