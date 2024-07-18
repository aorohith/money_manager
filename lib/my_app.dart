import 'dart:developer';
import 'package:daily_planner/services/route_service/routes_name.dart';
import 'package:daily_planner/utils/global_bindings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'services/route_service/router_config.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.routesConfig,
  });

  final RoutesConfig routesConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          // Hide the keyboard
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splash,
        // darkTheme: ThemeColor().getThemeData(isDark: true),
        // theme: ThemeColor().getThemeData(isDark: false),
        // themeMode: ThemeMode.light,
        initialBinding: GlobalBindings(),
        transitionDuration: const Duration(milliseconds: 500),
        defaultTransition: Transition.rightToLeft,
        defaultGlobalState: true,
        getPages: widget.routesConfig.getGetXPages(),
        onReady: () async {
          log("is Ready is call");
        },
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: child!,
        ),
      ),
    );
  }
}
