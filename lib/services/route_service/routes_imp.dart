import 'package:daily_planner/UI/screens/login/login.dart';
import 'package:daily_planner/services/route_service/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutesImp implements RoutesConfig {
  @override
  List<GetPage> getGetXPages() {
    return [
      GetPage(
        name: RoutesName.splash,
        page: () => const LoginUi(),
        binding: LoginBinding(),
      ),
      GetPage(
        name: RoutesName.login,
        page: () => const LoginUi(),
        binding: LoginBinding(),
      ),
    ];
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null;
  }
}
