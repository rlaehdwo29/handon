import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MainService with ChangeNotifier {
  final mainList = List.empty(growable: true).obs;

  NotificatioMainServicenService() {
    mainList.value = List.empty(growable: true);
  }

  void init() {
    mainList.value = List.empty(growable: true);
  }

}