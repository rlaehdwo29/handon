

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/main.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';


// ignore: must_be_immutable
class SettingPage extends StatefulWidget{
  UserModel? user;

   SettingPage({Key? key, this.user}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  ProgressDialog? pr;
  final controller = Get.find<App>();
  final checkLanguage = "ko".obs;   // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어
  final select_farm = Map<String,dynamic>().obs;
  final appVersion = "0.0".obs;
  final appMinSdk = "0".obs;

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, () async {
      select_farm.value = {"farm_no": widget.user?.last_farm_no, "farm_nm" : widget.user?.last_farm_nm};
      checkLanguage.value = await controller.getLanguage();
      changeLanguage(context, checkLanguage.value);
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value  = packageInfo.version;
      appMinSdk.value = packageInfo.buildNumber;
    });

  }

  /**
   * Widget Start
   */

  Widget bodyWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(30.0)),
      decoration: const BoxDecoration(
        color: Color(0xffe3d8ee),
          borderRadius:BorderRadius.all(Radius.circular(0))
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: CustomStyle.getWidth(10),top: CustomStyle.getHeight(5)),
            child:  Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
                return Obx(() => Text(
                  menuProvider.translate('language'),
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(checkLanguage.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black,
                      font_weight: FontWeight.w800),
                  )
                );
              })
          ),
          // 다국어 변경 Image Button
          Container(
              padding: EdgeInsets.symmetric(vertical:  CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "ko";
                        controller.setLanguage(checkLanguage.value);
                        changeLanguage(context, checkLanguage.value);
                        setState(() {});
                      },
                      child: Container(
                        decoration: checkLanguage.value == "ko" ? BoxDecoration(
                            border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffe3d8ee), width: 3)
                        ),
                        child: Image.asset(
                          "assets/image/ic_cir_ko.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                        ),
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "ne";
                        controller.setLanguage(checkLanguage.value);
                        changeLanguage(context, checkLanguage.value);
                        setState(() {});
                      },
                      child: Container(
                        decoration: checkLanguage.value == "ne" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffe3d8ee), width: 3)
                        ),
                        child:  Image.asset(
                          "assets/image/ic_cir_ne.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                        ),
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "my";
                        controller.setLanguage(checkLanguage.value);
                        changeLanguage(context, checkLanguage.value);
                        setState(() {});
                      },
                      child: Container(
                        decoration: checkLanguage.value == "my" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffe3d8ee), width: 3)
                        ),
                        child: Image.asset(
                          "assets/image/ic_cir_mi.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                        ),
                    )
                  ),
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "km";
                        controller.setLanguage(checkLanguage.value);
                        changeLanguage(context, checkLanguage.value);
                        setState(() {});
                      },
                      child: Container(
                        decoration: checkLanguage.value == "km" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffe3d8ee), width: 3)
                        ),
                        child:  Image.asset(
                          "assets/image/ic_cir_cam.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                        ),
                    )
                  )
                ],
              )
          ),
        ],
      ),
    );
  }


  /**
   * Widget End
   */



  /**
   * Funcion Start
   */
  void changeLanguage(BuildContext context, String languageCode) async {
    //final translations = await MenuProvider.getCode(languageCode);
    context.read<MenuProvider>().loadTranslations(languageCode);

    MyApp.setLocale(context, Locale(languageCode,languageCode == "ko" ? "KR" : languageCode == "ne" ? "NE" : languageCode == "my" ? "MY" : "KM"));
  }

  /**
   * Function End
   */

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final height = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
    final width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return true;
        },
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: main_color,
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop({'code':100});
          },
          color: Colors.white,
          icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.white),
        ),
        title: Consumer<MenuProvider>(
            builder: (context, menuProvider, child) {
              return Obx(() => Text(
                  menuProvider.translate('setting'),
                  style: CustomStyle.CustomFont(checkLanguage.value == "ko" ? styleFontSize18 : styleFontSize14, Colors.white)
                )
              );
            }),
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
      ),
          body: SafeArea(
                child: Obx(() {
                  return Container(
                      width: width,
                      height: height,
                      color: const Color(0xffededed),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: CustomStyle.getHeight(40)),
                              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.95,
                              height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.2,
                              child: Image.asset(
                                "assets/image/doni_guardT.png",
                                fit: BoxFit.fill,
                              )
                          ),
                          bodyWidget(),
                          Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                child: Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                            menuProvider.translate('select_farm'),
                                            style: CustomStyle.CustomFont(checkLanguage.value == "ko" ? styleFontSize18 : styleFontSize14, Colors.black,font_weight: FontWeight.w800),
                                          ));
                                    })
                                ),
                                DropdownButton<Map<String, dynamic>>(
                                  value: widget.user?.farm_list?.firstWhere(
                                        (element) => element["farm_no"] == select_farm["farm_no"],
                                    orElse: () => null,
                                  ),
                                  itemHeight: 60.0,
                                  alignment: Alignment.center,
                                  items: widget.user?.farm_list?.map((e) => DropdownMenuItem<Map<String, dynamic>>(
                                    value: e, // 선택 시 반환될 값
                                    child: Text(
                                      e["farm_nm"] ?? "",
                                      style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                                    ),
                                  )).toList(),
                                  onChanged: (Map<String, dynamic>? newValue) { // DropdownMenuItem의 value 반환
                                    setState(() {
                                      select_farm.value = newValue ?? {};
                                      widget.user?.last_farm_nm = select_farm["farm_nm"];
                                      widget.user?.last_farm_no = select_farm["farm_no"];
                                      controller.setUserInfo(widget.user?.user_id, widget.user?.login_yn, widget.user?.access_key, widget.user?.user_nm, widget.user?.last_farm_no, widget.user?.last_farm_nm, widget.user?.list_count, widget.user?.farm_list, widget.user?.autoYn);
                                    });
                                  },
                                  underline: Container(
                                    height: 3,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(30)),
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(30), vertical: CustomStyle.getWidth(10)),
                            decoration: const BoxDecoration(
                              color: CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                            "${menuProvider.translate('version_title')}: V${appVersion.value}",
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(checkLanguage.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black),
                                          ));
                                    }),
                                Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                      return  Obx(() => Text(
                                            "${menuProvider.translate('service_no')}: HPA20241130",
                                            style: CustomStyle.CustomFont(checkLanguage.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black),
                                          ));
                                    }),
                              ],
                            ),
                          )
                        ],
                      )
                  );
                })
            )
    ));
  }

}