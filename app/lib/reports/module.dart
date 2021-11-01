import 'package:auto_route/auto_route.dart';

import 'pages/reports.dart';

export 'pages/reports.dart';

const reportsRoutes = AutoRoute(
  path: 'reports',
  name: 'ReportsRouter',
  page: EmptyRouterPage,
  children: <AutoRoute>[
    AutoRoute(path: '', page: ReportsPage),
  ],
);
