

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/page/login_page.dart';
import 'package:handon_project/page/main_page.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  _BridgePageState createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  final controller = Get.find<App>();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await goToLogin();    // 첫 로딩화면 Login 페이지로 이동
    });

  }

  @override
  void dispose(){
    super.dispose();
  }

  /**
   * Login Page 이동 Function
   */
  Future goToLogin() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const LoginPage())
    );
  }

  /**
   * Main Page 이동 Function
   */
  Future goToMain() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const MainPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        backgroundColor: styleGreyCol1,
      )
    );
  }

}