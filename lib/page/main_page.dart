import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_main_widget.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/constants/const.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/page/level_1/accident_page.dart';
import 'package:handon_project/page/level_1/individual_page.dart';
import 'package:handon_project/page/level_1/dead_page.dart';
import 'package:handon_project/page/level_1/setting_page.dart';
import 'package:handon_project/page/level_1/wean_page.dart';
import 'package:handon_project/page/level_1/mating_page.dart';
import 'package:handon_project/page/level_1/work_page.dart';
import 'package:handon_project/page/login_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/sp.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // for rootBundle

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> with CommonMainWidget, WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final controller = Get.find<App>();
  final mUser = UserModel().obs;
  final language = "my".obs;  // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * Start Widget
   */

  // Drawer 메뉴바
    Drawer getAppBarMenu() {
      return Drawer(
        backgroundColor: const Color(0xff1d1b20),
        width: App().isTablet(context) ? MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.6 : MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.7,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            )
        ),
        child: Column(
          children: [
            Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: App().isTablet(context) ? 200.h : 180.h,
                      child: DrawerHeader(
                          decoration: const BoxDecoration(
                            color: main_color
                          ),
                          padding: EdgeInsetsDirectional.only(top: CustomStyle.getHeight(0)),
                          child: Row(
                            children: [
                              Expanded(
                                  flex:1,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children:[
                                                      Container(
                                                          margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                                          child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children:[
                                                                // Appbar top 이미지
                                                                Row(
                                                                  children: [
                                                                    Image.asset(
                                                                      "assets/image/img_handon_logoT.png",
                                                                      width: CustomStyle.getWidth(38.0),
                                                                      height: CustomStyle.getHeight(38.0),
                                                                    ),
                                                                    Image.asset(
                                                                      "assets/image/img_handon_600wT.png",
                                                                      width: CustomStyle.getWidth(68.0),
                                                                      height: CustomStyle.getHeight(38.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                                CustomStyle.sizedBoxHeight(3.0),
                                                                Obx(() => Text(
                                                                  "${mUser.value.last_farm_nm}",  // Appbar 농장명
                                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                                                  )
                                                                ),
                                                                Obx(() => Text(
                                                                  "${mUser.value.user_id}",   // Appbar User ID명
                                                                  style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                                                  )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                    ]
                                                )
                                            )
                                        ),
                                      ]
                                  )
                              )
                            ],
                          )
                      )),
                      // AppBar 교배관리 Tab
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        title: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                          child: Row(
                            children: [
                              Expanded(
                                flex:1,
                                child: SizedBox(
                                    width: CustomStyle.getWidth(45),
                                    height: CustomStyle.getHeight(25),
                                    child: Image.asset(
                                      "assets/image/img_mating.png",
                                      fit: BoxFit.fill,
                                      color: const Color(0xffa29da7),
                                    )
                                )
                              ),
                              Expanded(
                                flex:4,
                                child: Container(
                                    margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                    child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                        menuProvider.translate('mate_manager'),   // <다국어> 교배관리
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11,const Color(0xffa29da7),font_weight: FontWeight.w800),
                                      ));
                                    })
                                )
                              )
                            ],
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await goToManage();   // 
                        },
                      ),
                      // AppBar 분만관리 Tab
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        title: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                          child: Row(
                            children: [
                              Expanded(
                                flex:1,
                                child: Container(
                                    width: CustomStyle.getWidth(45),
                                    height: CustomStyle.getHeight(20),
                                    child: Image.asset(
                                      "assets/image/img_farrowing.png",
                                      fit: BoxFit.fill,
                                      color: const Color(0xffa29da7),
                                    )
                                )
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                      margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                      child: Consumer<MenuProvider>(
                                          builder: (context, menuProvider, child) {
                                            return Obx(() => Text(
                                                  menuProvider.translate('work_manager'),   // <다국어> 분만관리
                                                  softWrap: true,
                                                  textAlign: TextAlign.left,
                                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11,const Color(0xffa29da7),font_weight: FontWeight.w800),
                                                ));
                                          })
                                )
                              )
                            ],
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await goToWork();   // 교배관리 페이지 이동
                        },
                      ),
                      // AppBar 이유관리 Tab
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                        title: Container(
                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                    width: CustomStyle.getWidth(45),
                                    height: CustomStyle.getHeight(25),
                                    child: Image.asset(
                                      "assets/image/img_weaning.png",
                                      fit: BoxFit.fill,
                                      color: const Color(0xffa29da7),
                                    )
                                )
                              ),
                              Expanded(
                                flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                  return Obx(() => Text(
                                        menuProvider.translate('wean_manager'),   // <다국어> 이유관리
                                        textAlign: TextAlign.left,
                                        softWrap: true,
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7), font_weight: FontWeight.w800),
                                      ));
                                })
                              ))
                            ],
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                            await goToWean();   // 이유관리 페이지  이동
                        },
                      ),
                    // AppBar 임신사고관리 Tab
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  width: CustomStyle.getWidth(45),
                                  height: CustomStyle.getHeight(25),
                                  child: Image.asset(
                                    "assets/image/img_prcheck.png",
                                    fit: BoxFit.fill,
                                    color: const Color(0xffa29da7),
                                  )
                              )
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child:  Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                    return Obx(() => Text(
                                      menuProvider.translate('accident_manager'),   // <다국어> 임신사고관리
                                      softWrap: true,
                                      textAlign: TextAlign.left,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7),
                                      font_weight: FontWeight.w800),
                                      )
                                    );
                                    })
                              )
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await goToAccident();   // 임신사고관리 페이지 이동
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: SizedBox(
                                  width: CustomStyle.getWidth(45),
                                  height: CustomStyle.getHeight(25),
                                  child: Image.asset(
                                    "assets/image/img_culling.png",
                                    fit: BoxFit.fill,
                                    color: const Color(0xffa29da7),
                                  )
                              )
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                    return Obx(() => Text(
                                      menuProvider.translate('out_manager'),    // <다국어> 도폐사 관리
                                      softWrap: true,
                                      textAlign: TextAlign.left,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7),
                                      font_weight: FontWeight.w800),
                                      )
                                    );
                                  })
                              )
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await goToDead();   // 도폐사 관리 페이지 이동
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                  width: CustomStyle.getWidth(25),
                                  height: CustomStyle.getHeight(25),
                                  child: Image.asset(
                                    "assets/image/img_sowcard.png",
                                    fit: BoxFit.fill,
                                    color: const Color(0xffa29da7),
                                  )
                              )
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                    return Obx(() => Text(
                                        menuProvider.translate('individual_manager'),   // <다국어> 개체관리
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7),
                                        font_weight: FontWeight.w800),
                                      )
                                    );
                                  })
                              )
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await goToIndividual();     // 개체관리 페이지 이동
                      },
                    ),
                    Container(
                      height: CustomStyle.getHeight(3.0),
                      color: const Color(0xffa29da7),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.settings,
                                size: 28,
                                color: Color(0xffa29da7),
                              )
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                          menuProvider.translate('setting'),    // <다국어> 설정
                                          softWrap: true,
                                          textAlign: TextAlign.left,
                                          style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7),
                                          font_weight: FontWeight.w800),
                                        )
                                      );
                                    })
                              )
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await goToSetting();    // 설정 페이지 이동
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w)),
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Icon(
                                Icons.logout,
                                size: 28,
                                color: Color(0xffa29da7),
                              )
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                                  child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                          menuProvider.translate('logout'),     // <다국어> 로그아웃
                                          softWrap: true,
                                          textAlign: TextAlign.left,
                                          style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize11, const Color(0xffa29da7),
                                          font_weight: FontWeight.w800),
                                        )
                                      );
                                    })
                              )
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        await goToExit();   // 로그아웃 Function
                      },
                    )
                  ],
                )
            ),
          ],
        ),
      );
    }

    //메인화면 Widget
    Widget mainMenu() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
          child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 교배 메뉴
              InkWell(
                  onTap: (){
                    goToManage();   // 교배 페이지 이동
                  },
                  child: Container(
                      width: CustomStyle.getWidth(150),
                      height: CustomStyle.getHeight(120),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                      decoration: const BoxDecoration(
                        color: sub_color,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(65),
                              child: Image.asset(
                                "assets/image/img_mating.png",
                                fit: BoxFit.fill,
                              )
                          ),
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Obx(() => Text(
                                menuProvider.translate('mate'),     // <다국어> 교배
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize13,Colors.black,font_weight: FontWeight.w800),
                              ));
                            })
                        ],
                      )
                  )
              ),
              // 분만 메뉴
              InkWell(
                  onTap: (){
                    goToWork();   // 분만 페이지 이동
                  },
                  child: Container(
                      width: CustomStyle.getWidth(150),
                      height: CustomStyle.getHeight(120),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                      decoration: const BoxDecoration(
                        color: sub_color,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(65),
                              child: Image.asset(
                                "assets/image/img_farrowing.png",
                                fit: BoxFit.fill,
                              )
                          ),
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Obx(() => Text(
                                menuProvider.translate('work'),     // <다국어> 분만
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize13,Colors.black,font_weight: FontWeight.w800),
                            ));
                          })
                        ],
                      )
                  )
              )
            ],
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 이유 메뉴
                  InkWell(
                      onTap: (){
                        goToWean();   // 이유 페이지 이동
                      },
                      child: Container(
                          width: CustomStyle.getWidth(150),
                          height: CustomStyle.getHeight(120),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          decoration: const BoxDecoration(
                            color: sub_color,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                  width: CustomStyle.getWidth(100),
                                  height: CustomStyle.getHeight(45),
                                  child: Image.asset(
                                    "assets/image/img_weaning.png",
                                    fit: BoxFit.fill,
                                  )
                              ),
                              Consumer<MenuProvider>(
                                  builder: (context, menuProvider, child) {
                                    return Obx(() => Text(
                                      menuProvider.translate('wean'),     // <다국어> 이유
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize13,Colors.black,font_weight: FontWeight.w800),
                                    ));
                                  })
                            ],
                          )
                      )
                  ),
                  // 임신사고 메뉴
                  InkWell(
                      onTap: () async {
                        await goToAccident();   // 임신사고 페이지 이동
                      },
                      child: Container(
                          width: CustomStyle.getWidth(150),
                          height: CustomStyle.getHeight(120),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          decoration: const BoxDecoration(
                            color: sub_color,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: CustomStyle.getWidth(100),
                                  height: CustomStyle.getHeight(65),
                                  child: Image.asset(
                                    "assets/image/img_prcheck.png",
                                    fit: BoxFit.fill,
                                  )
                              ),
                              Consumer<MenuProvider>(
                                  builder: (context, menuProvider, child) {
                                    return Obx(() => Text(
                                      menuProvider.translate('accident'),       // <다국어> 임신사고
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize12,Colors.black,font_weight: FontWeight.w800),
                                      )
                                    );
                                  })
                            ],
                          )
                      )
                  )
                ],
              )
          ),
          // 세번째 메뉴
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 도폐사 메뉴
              InkWell(
                  onTap: ()async {
                    await goToDead();   // 도폐사 페이지 이동
                  },
                  child: Container(
                      width: CustomStyle.getWidth(150),
                      height: CustomStyle.getHeight(120),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                      decoration: const BoxDecoration(
                        color: sub_color,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(65),
                              child: Image.asset(
                                "assets/image/img_culling.png",
                                fit: BoxFit.fill,
                              )
                          ),
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Obx(() =>Text(
                                      menuProvider.translate('out'),        // <다국어> 도폐사
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize13,Colors.black,font_weight: FontWeight.w800),
                                    )
                                );
                              })
                        ],
                      )
                  )
              ),
              // 개체관리 메뉴
              InkWell(
                  onTap: () async {
                    await goToIndividual();   // 개체관리 페이지 이동
                  },
                  child: Container(
                      width: CustomStyle.getWidth(150),
                      height: CustomStyle.getHeight(120),
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                      decoration: const BoxDecoration(
                        color: sub_color,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: CustomStyle.getWidth(100),
                              height: CustomStyle.getHeight(65),
                              child: Image.asset(
                                "assets/image/img_sowcard.png",
                                fit: BoxFit.fill,
                              )
                          ),
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Obx(() =>Text(
                                      menuProvider.translate('individual_manager'),       // <다국어> 개체관리
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize13,Colors.black,font_weight: FontWeight.w800),
                                    ));
                              })
                        ],
                      )
                  )
              )
            ],
          )
        ],
        )
      );
    }

  /**
   * 로그아웃 Function
   */
  Future<void> goToExit() async {
    openCommonConfirmBox(
        context,
        "msg_request_logout",
        "no",
        "yes",
            () {Navigator.of(context).pop(false);},
            () async {
          var it = await SP.getBoolean(Const.CD_SAVE_ID);
          if(!it) await SP.remove(Const.CD_USER_ID);  // 내부 DB에 아이디가 저장되어 있으면 데이터 삭제
          await SP.remove(Const.CD_USER_PW);  // 내부 DB에 저장된 패스워스 제거
          await SP.remove(Const.CD_USER_AUTO);  // 내부 Db에 저장된 자동로그인 데이터 제거
          await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),(route) => false);
        }
    );
  }
  /**
   * End Widget
   */


  /**
   * Start Function
   */

  //교배 화면으로 이동
  Future<void> goToManage() async {
    await Navigator.of(context).push(PageAnimationTransition(page: MatingPage(), pageAnimationType: RightToLeftFadedTransition()));
  }

  //분만 화면으로 이동
  Future<void> goToWork() async {
    await Navigator.of(context).push(PageAnimationTransition(page: WorkPage(), pageAnimationType: RightToLeftFadedTransition()));
  }

  // 이유 화면으로 이동
  Future<void> goToWean() async {
    await Navigator.of(context).push(PageAnimationTransition(page: WeanPage(), pageAnimationType: RightToLeftFadedTransition()));
  }

  //임신사고 화면으로 이동
  Future<void> goToAccident() async {
    await Navigator.of(context).push(PageAnimationTransition(page: AccidentPage(), pageAnimationType: RightToLeftFadedTransition()));
  }

  // 도폐사 화면으로 이동
  Future<void> goToDead() async {
    await Navigator.of(context).push(PageAnimationTransition(page: DeadPage(), pageAnimationType: RightToLeftFadedTransition()));
  }


  //개체 화면으로 이동
  Future<void> goToIndividual() async {
    await Navigator.of(context).push(PageAnimationTransition(page: IndividualPage(), pageAnimationType: RightToLeftFadedTransition()));
  }

  // 설정 화면으로 이동
  Future<void> goToSetting() async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: SettingPage(user: mUser.value), pageAnimationType: RightToLeftFadedTransition()));

    if(results.containsKey("code")){
      language.value = await controller.getLanguage();
      }
  }


  /**
   * /End Function
   */


  @override
  Widget build(BuildContext mContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: main_color,
        toolbarHeight: 50.h,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder:(context) => IconButton(
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              tooltip: MaterialLocalizations.of(mContext).openAppDrawerTooltip,
              icon: const Icon(
                  Icons.menu,
                color: Colors.white,
                size: 32,
              ),
          )
        ),
        title: Row(
          children: [
            Image.asset(
              "assets/image/img_handon_logoT.png",
              width: CustomStyle.getWidth(28.0),
              height: CustomStyle.getHeight(28.0),
            ),
            Image.asset(
              "assets/image/img_handon_600wT.png",
              width: CustomStyle.getWidth(85.0),
              height: CustomStyle.getHeight(50.0),
            ),
          ],
        )
      ),
        drawer: getAppBarMenu(),    // 왼쪽 상단 메뉴바
      body: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(30)),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.95,
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.2,
                  child: Image.asset(
                    "assets/image/img_doni_familyT.png",
                    fit: BoxFit.fill,
                  )
              ),
              mainMenu()    // 메인화면 Widget
            ],
          )
      ),
    );
  }

}