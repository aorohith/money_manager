import 'package:daily_planner/my_app.dart';
import 'package:flutter/material.dart';
import 'services/route_service/routes_imp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      routesConfig: RoutesImp(),
    ),
  );
}
