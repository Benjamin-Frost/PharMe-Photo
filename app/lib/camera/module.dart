import '../common/module.dart';
import 'pages/camera.dart';

// We need to expose all pages for AutoRouter
export 'pages/camera.dart';

const cameraRoutes = AutoRoute(
  path: 'camera',
  name: 'CameraRouter',
  page: CameraPage,
);
