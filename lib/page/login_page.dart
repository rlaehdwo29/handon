

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_main_widget.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/constants/const.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/main.dart';
import 'package:handon_project/page/main_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/sp.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../utils/util.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with CommonMainWidget {

  ProgressDialog? pr;
  final controller = Get.find<App>();
  final userID = "".obs;
  final userPW = "".obs;
  final checkLanguage = "ko".obs;   // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어
  final autoLogin = true.obs;       // 자동 로그인 유무
  final saveId = true.obs;          // ID 저장 유무
  late TextEditingController userIdController;


  @override
  void initState(){
    super.initState();
    userIdController = TextEditingController();
    Future.delayed(Duration.zero, () async {
      bool auto = await SP.getBoolean(Const.CD_USER_AUTO);    // 단말기 DB 내 저장된 "자동로그인" 데이터 세팅
      bool saveId = await SP.getBoolean(Const.CD_SAVE_ID);    // 단말기 DB 내 저장된 "아이디 저장" 데이터 세팅
      checkLanguage.value = await controller.getLanguage();   // 단말기 Db 내 저장된 언어 가져오기
      changeLanguage(context, checkLanguage.value);           // 앱 언어 세팅 Function
      if(auto) {  // 자동로그인이 체크퇴어 있으면 저장된 ID,PW 값으로 로그인
        String? uId = await SP.getString(Const.CD_USER_ID, "");
        String? uPw = await SP.getString(Const.CD_USER_PW, "");
        userID.value = uId??"";
        userPW.value = uPw??"";
        await goLogin();    // 로그인 처리 API
      } else if(saveId) {   // save ID가 저장되어 있으면 Id TextField에 삽입.
        String? uId = await SP.getString(Const.CD_USER_ID, "");
        userID.value = uId??"";
        userIdController.text = userID.value;
      }
    });

  }

  /**
   * Widget Start
   */

  // 상단 Banner Widget
  Widget topSubBanner() {
    return Container(
        color: const Color(0xff0a4db1),
        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      return Text(
                          menuProvider.translate('handon_center'), // <다국어> 한돈전산센터
                          maxLines: 1, // 한 줄로 제한
                          overflow: TextOverflow.ellipsis,
                          style: CustomStyle.CustomFont(checkLanguage.value == "00" ? styleFontSize14 : styleFontSize11, Colors.white),
                      );
                    }),
                Container(
                    margin: EdgeInsets.only(top: CustomStyle.getHeight(3)),
                    child: Text(
                      "02-6486-2906",
                      style: CustomStyle.CustomFont(checkLanguage.value == "00" ? styleFontSize14 : styleFontSize11, Colors.white,font_weight: FontWeight.w800),
                    )
                )
              ],
            ),
            Container(
                margin: EdgeInsets.only(left: CustomStyle.getWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return Text(
                              menuProvider.translate('qna'),  // <다국어> 문의사항
                              style: CustomStyle.CustomFont(
                                  checkLanguage.value == "00" ? styleFontSize14 : styleFontSize11, Colors.white)
                          );
                        }),
                    Text(
                      "handoninstitute@naver.com",
                      style: CustomStyle.CustomFont(checkLanguage.value == "00" ? styleFontSize14 : styleFontSize11, Colors.white,font_weight: FontWeight.w800),
                    )
                  ],
                )
            )
          ],
        )
    );
  }

  Widget bodyWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(30.0)),
      child: Column(
        children: [
          // 다국어 변경 Image Button
          Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 한국어 Button
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "ko";
                        changeLanguage(context, 'ko');    // 앱 언어 세팅 Function
                        controller.setLanguage(checkLanguage.value);    // 단말기 내부 DB에 언어 데이터 저장
                        setState(() {});
                      },
                      child: Obx(() => Container(
                        decoration: checkLanguage.value == "ko" ? BoxDecoration(
                            border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffededed), width: 3)
                        ),
                        child: Image.asset(
                          "assets/image/ic_cir_ko.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                          fit: BoxFit.fill
                        ),
                      )
                    )
                  ),
                  // 네팔어 Button
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "ne";
                        changeLanguage(context, 'ne');    // 앱 언어 세팅 Function
                        controller.setLanguage(checkLanguage.value);    // 단말기 내부 DB에 언어 데이터 저장
                        setState(() {});
                      },
                      child: Obx(() => Container(
                        decoration: checkLanguage.value == "ne" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffededed), width: 3)
                        ),
                        child:  Image.asset(
                          "assets/image/ic_cir_ne.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                          fit: BoxFit.fill
                        ),
                      )
                    )
                  ),
                  // 미얀마어 Button
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "my";
                        changeLanguage(context, 'my');    // 앱 언어 세팅 Function
                        controller.setLanguage(checkLanguage.value);    // 단말기 내부 DB에 언어 데이터 저장
                        setState(() {});
                      },
                      child: Obx(() => Container(
                        decoration: checkLanguage.value == "my" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffededed), width: 3)
                        ),
                        child: Image.asset(
                          "assets/image/ic_cir_mi.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                          fit: BoxFit.fill
                        ),
                      )
                      )
                  ),
                  // 캄보디아어 Button
                  InkWell(
                      onTap: () async {
                        checkLanguage.value = "km";
                        changeLanguage(context, 'km');    // 앱 언어 세팅 Function
                        controller.setLanguage(checkLanguage.value);    // 단말기 내부 DB에 언어 데이터 저장
                        setState(() {});
                      },
                      child: Obx(() => Container(
                        decoration: checkLanguage.value == "km" ? BoxDecoration(
                          border:Border.all(color: const Color(0xffffc000), width: 3)
                        ) : BoxDecoration(
                          border:Border.all(color: const Color(0xffededed), width: 3)
                        ),
                        child:  Image.asset(
                          "assets/image/ic_cir_cam.png",
                          width: CustomStyle.getWidth(52.0),
                          height: CustomStyle.getHeight(52.0),
                          fit: BoxFit.fill
                        ),
                      )
                    )
                  )
                ],
              )
          ),
          CustomStyle.getDivider2(),
          // 아이디 TextFeild
          Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(20),top: CustomStyle.getHeight(30)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                      child: Text(
                        "ID  ",
                        style: CustomStyle.CustomFont(styleFontSize18, const Color(0xff666666), font_weight:  FontWeight.w800),
                      )
                  ),
                  Container(
                      width: CustomStyle.getWidth(250),
                      height: CustomStyle.getHeight(50),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xff1f6ee6))
                      ),
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                        textAlign: TextAlign.start,
                        controller: userIdController,
                        keyboardType: TextInputType.text,

                        onChanged: (value){
                          userID.value = value;
                        },
                        maxLength: 50,
                        decoration: InputDecoration(
                            counterText: '',
                            hintText: "id",
                            hintStyle:CustomStyle.CustomFont(styleFontSize14, light_gray2),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            border: InputBorder.none
                        ),
                      )
                  ),
                ],
              )
          ),

          // 패스워드 TextFeild
          Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(30)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                      child: Text(
                        "PW",
                        style: CustomStyle.CustomFont(styleFontSize18, const Color(0xff666666), font_weight: FontWeight.w800),
                      )
                  ),
                  Container(
                      width: CustomStyle.getWidth(250),
                      height: CustomStyle.getHeight(50),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xff1f6ee6))
                      ),
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (value){
                          userPW.value = value;
                        },
                        maxLength: 50,
                        decoration: InputDecoration(
                            counterText: '',
                            hintText: "password",
                            hintStyle:CustomStyle.CustomFont(styleFontSize14, light_gray2),
                            contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                            border: InputBorder.none
                        ),
                      )
                  ),
                ],
              )
          ),
          CustomStyle.getDivider2(),
          // 자동 로그인, 아이디/비밀번호 찾기 Button
          Container(
              margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: (){
                        setState(() {
                          saveId.value = !saveId.value;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                              value: saveId.value,
                              onChanged:(value) {
                                setState(() {
                                  saveId.value = !saveId.value;
                                });
                              }
                          ),
                          Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                menuProvider.translate('login_save_id'), // <다국어> 아이디저장
                                style: CustomStyle.CustomFont(checkLanguage.value == "00" ? styleFontSize14 : styleFontSize10, Colors.black)
                            );
                          })
                        ],
                      )
                  ),
                  InkWell(
                      onTap: (){
                        setState(() {
                          autoLogin.value = !autoLogin.value;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                              value: autoLogin.value,
                              onChanged:(value) {
                                setState(() {
                                  autoLogin.value = !autoLogin.value;
                                });
                              }
                          ),
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Text(
                                    menuProvider.translate('login_auto_save'),  // <디국어> 자동로그인
                                    style: CustomStyle.CustomFont(checkLanguage.value == "00" ? styleFontSize14 : styleFontSize10, Colors.black)
                                );
                              })
                        ],
                      )
                  ),
                ],
              )
          ),
          // 로그인 Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: sub_color,
              backgroundColor: main_color,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              await goLogin();    // Login Page 이동
            },
            child: Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
            // 번역된 텍스트를 표시
            return Text(
              //  <다국어> 로그인
            menuProvider.translate('login_login')?.trim().isEmpty == true ? "로그인" : menuProvider.translate('login_login'),
            style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
            );
            })
          )
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

  /**
   * Login 처리 API
   */
  Future<void> goLogin() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).login("K",userID.value, userPW.value).then((it) async {
      await pr?.hide();
      ReturnLoginMap _response = DioService.dioLoginResponse(it);
      logger.i("goLogin() Response => ${_response.access_key} || ${_response.farm_list}");
      if (_response.access_key != null) {
        await controller.setUserInfo(_response.user_id, _response.login_yn, _response.access_key, _response.user_nm, _response.last_farm_no, _response.last_farm_nm, _response.list_count, _response.farm_list ,autoLogin.value);
        if(autoLogin.value) { // 자동로그인 체크 시 자동로그인을 위한 내부 DB에 저장
          await SP.putString(Const.CD_USER_ID, userID.value);   // 단말기 DB 아이디 저장
          await SP.putString(Const.CD_USER_PW, userPW.value);   // 단말기 DB 패스워드 저장
          await SP.putBool(Const.CD_SAVE_ID, saveId.value);     // 단말기 DB 아이디 저장 Check 여부 저장
          await SP.putBool(Const.CD_USER_AUTO, autoLogin.value);  // 단말기 DB 자동로그인 Check 여부 저장
        }
        if(saveId.value){   // 아이디 저장 시 내부 DB에 데이터 저장
          await SP.putString(Const.CD_USER_ID, userID.value);   // 단말기 DB 아이디 저장
          await SP.putBool(Const.CD_SAVE_ID, autoLogin.value);  // 단말기 DB 아이디저장 Check 여부 저장
        }
        goToMain();   // 메인페이지 이동
      } else {
        Util.toast(context.read<MenuProvider>().translate('msg_no_id'));  // <다국어> 계정이 존재하지 않습니다.
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));  // <다국어> 서버연결에 문제가 있습니다.
      await pr?.hide();
      switch(obj.runtimeType) {
      case DioError:
      final res = (obj as DioError).response;
      logger.e("login_page.dart goLogin() error : ${res?.statusCode} -> ${res?.statusMessage}");
      break;
      default:
      logger.e("login_page.dart goLogin() default Error :");
      break;
      }
    });
  }

  /**
   * MainPage 이동 Function
   */
  void goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const MainPage()),
            (route) => false);
  }


  // 앱 언어 세팅 Function
  void changeLanguage(BuildContext context, String languageCode) async {
    context.read<MenuProvider>().loadTranslations(languageCode);

    MyApp.setLocale(context, Locale(languageCode));
  }
  /**
   * Function End
   */

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final height = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
    final width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;

    return mainWidget(
        context,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView (
              child: SafeArea(
                child: Container(
                  width: width,
                  height: height,
                  color:const Color(0xffededed),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 배너 이미지
                      SizedBox(
                        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
                        height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.35,
                        child: Image.asset(
                          "assets/image/img_handon_login_new.png",
                          fit: BoxFit.fill,
                        )
                      ),
                      // 문의사항 이메일, 전화번호 Widget
                      topSubBanner(),
                      // 다국어, ID/PW 입력 TextField, 자동로그인, ID저장, 로그인 버튼 Widget
                      bodyWidget()
                    ],
                  )
                )
            )
          ),
        )
    );
  }

}