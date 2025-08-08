// services/achievements_service.dart  (часть)

import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';

const achievementsCatalog = <AchievementDef>[
  // 1) Стрики
  AchievementDef(
    id: 'streak_3',
    title: '3-Day Streak',
    desc: 'Complete habits 3 days',
    kind: AchievementKind.streakDays,
    target: 3,
  ),
  AchievementDef(
    id: 'streak_7',
    title: '7-Day Streak',
    desc: 'Complete habits 7 days',
    kind: AchievementKind.streakDays,
    target: 7,
  ),
  AchievementDef(
    id: 'streak_14',
    title: '14-Day Streak',
    desc: 'Complete habits 14 days',
    kind: AchievementKind.streakDays,
    target: 14,
  ),
  AchievementDef(
    id: 'streak_30',
    title: '30-Day Streak',
    desc: 'Complete habits 30 days',
    kind: AchievementKind.streakDays,
    target: 30,
  ),
  AchievementDef(
    id: 'streak_60',
    title: '60-Day Streak',
    desc: 'Complete habits 60 days',
    kind: AchievementKind.streakDays,
    target: 60,
  ),
  AchievementDef(
    id: 'streak_100',
    title: '100-Day Streak',
    desc: 'Complete habits 100 days',
    kind: AchievementKind.streakDays,
    target: 100,
  ),
  AchievementDef(
    id: 'streak_365',
    title: '365-Day Streak',
    desc: 'Complete habits 365 days',
    kind: AchievementKind.streakDays,
    target: 365,
  ),

  // 2) Сэкономлено
  AchievementDef(
    id: 'saved_10',
    title: 'Saved \$10',
    desc: 'Save at least \$10',
    kind: AchievementKind.savedMoney,
    target: 10,
  ),
  AchievementDef(
    id: 'saved_50',
    title: 'Saved \$50',
    desc: 'Save at least \$50',
    kind: AchievementKind.savedMoney,
    target: 50,
  ),
  AchievementDef(
    id: 'saved_100',
    title: 'Saved \$100',
    desc: 'Save at least \$100',
    kind: AchievementKind.savedMoney,
    target: 100,
  ),
  AchievementDef(
    id: 'saved_250',
    title: 'Saved \$250',
    desc: 'Save at least \$250',
    kind: AchievementKind.savedMoney,
    target: 250,
  ),
  AchievementDef(
    id: 'saved_500',
    title: 'Saved \$500',
    desc: 'Save at least \$500',
    kind: AchievementKind.savedMoney,
    target: 500,
  ),
  AchievementDef(
    id: 'saved_1000',
    title: 'Saved \$1000',
    desc: 'Save at least \$1000',
    kind: AchievementKind.savedMoney,
    target: 1000,
  ),
  AchievementDef(
    id: 'saved_5000',
    title: 'Saved \$5000',
    desc: 'Save at least \$5000',
    kind: AchievementKind.savedMoney,
    target: 5000,
  ),

  // 3) Потрачено (вредные)
  AchievementDef(
    id: 'wasted_50',
    title: 'Wasted \$50',
    desc: 'Waste more than \$50',
    kind: AchievementKind.wastedMoney,
    target: 50,
  ),
  AchievementDef(
    id: 'wasted_200',
    title: 'Wasted \$200',
    desc: 'Waste more than \$200',
    kind: AchievementKind.wastedMoney,
    target: 200,
  ),

  // 4) Чистые дни
  AchievementDef(
    id: 'clean_1',
    title: '1 Clean Day',
    desc: 'Only good habits 1 day',
    kind: AchievementKind.cleanDays,
    target: 1,
  ),
  AchievementDef(
    id: 'clean_3',
    title: '3 Clean Days',
    desc: 'Only good habits 3 days',
    kind: AchievementKind.cleanDays,
    target: 3,
  ),
  AchievementDef(
    id: 'clean_7',
    title: '7 Clean Days',
    desc: 'Only good habits 7 days',
    kind: AchievementKind.cleanDays,
    target: 7,
  ),
  AchievementDef(
    id: 'clean_14',
    title: '14 Clean Days',
    desc: 'Only good habits 14 days',
    kind: AchievementKind.cleanDays,
    target: 14,
  ),
  AchievementDef(
    id: 'clean_30',
    title: '30 Clean Days',
    desc: 'Only good habits 30 days',
    kind: AchievementKind.cleanDays,
    target: 30,
  ),
  AchievementDef(
    id: 'clean_60',
    title: '60 Clean Days',
    desc: 'Only good habits 60 days',
    kind: AchievementKind.cleanDays,
    target: 60,
  ),
  AchievementDef(
    id: 'clean_100',
    title: '100 Clean Days',
    desc: 'Only good habits 100 days',
    kind: AchievementKind.cleanDays,
    target: 100,
  ),
];
