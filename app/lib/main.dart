import 'common/module.dart';

Future<void> main() async {
  // await initServices();
  // await fetchAndSaveLookups();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PharmeApp());
  // await cleanupServices();
}
