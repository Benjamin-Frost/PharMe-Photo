import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../login/module.dart';
import '../../medications/module.dart';
import '../../onboarding/module.dart';
import '../../pgx/module.dart';
import '../../profile/module.dart';
import '../../reports/module.dart';
import '../pages/main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    onboardingRoutes,
    loginRoutes,
    AutoRoute(
      path: 'main',
      page: MainPage,
      children: [
        medicationsRoutes,
        profileRoutes,
        pgxRoutes,
        reportsRoutes,
      ],
    ),
  ],
)
class AppRouter extends _$AppRouter {}
