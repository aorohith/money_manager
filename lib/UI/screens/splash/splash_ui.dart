import 'package:daily_planner/services/route_service/routes.dart';
import 'package:daily_planner/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashUI extends StatefulWidget {
  const SplashUI({super.key});

  @override
  State<SplashUI> createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []); // to only hide the status bar
    _navigateToHome();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  Future<void> _navigateToHome() async {
    RoutesName.login;
    await Future.delayed(const Duration(seconds: 3));
    Get.toNamed(RoutesName.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: Get.height,
      width: Get.width,
      color: ThemeColors.primaryColor,
    ));
  }
}
