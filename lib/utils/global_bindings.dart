import 'package:get/get.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() async {
    await initializeStateService();
    await initializeStateController();
  }
}

Future<void> initializeStateService() async {}

Future<void> initializeStateController() async {}
