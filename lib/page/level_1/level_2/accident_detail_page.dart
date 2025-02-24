
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_info_model.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/page/level_1/level_2/qr_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/util.dart';
import 'package:logger/logger.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AccidentDetailPage extends StatefulWidget {

  SowModel? sowModel;

  AccidentDetailPage({Key? key, required this.sowModel}) : super(key:key);

  _AccidentDetailPageState createState() => _AccidentDetailPageState();
}

class _AccidentDetailPageState extends State<AccidentDetailPage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();

  final mUser = UserModel().obs;
  final mSowInfoModel = SowInfoModel().obs;
  final mBreedList= List.empty(growable: true).obs;
  final page = 0.obs;
  final language = "my".obs;  // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
      await getSowDetail();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * Start Widget
   */

  /**
   * 모돈 정보 영역 Widget
   */
  Widget addidentDetail1Widget() {
    return Obx(() => Container(
      padding: EdgeInsets.only(top: CustomStyle.getHeight(10),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
      child: Column(
        children: [
          Row(
            children: [
              Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return  Text(
                      menuProvider.translate('sow_info'),       // <다국어> 모돈정보
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(
                          language.value == "ko" ? styleFontSize15 : styleFontSize13, Colors.black,font_weight: FontWeight.w800),
                    );
                  }),
              Container(
                padding: EdgeInsets.only(left: CustomStyle.getWidth(10)),
                child: Text(
                  "${widget.sowModel?.pig_coupon}",
                  style: CustomStyle.CustomFont(styleFontSize22, Colors.black, font_weight: FontWeight.w800),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
            decoration: BoxDecoration(
              border: Border.all(color: light_gray3, width: 1)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        alignment: Alignment.center,
                        height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: light_gray3,
                              width: 1
                            ),
                              bottom: BorderSide(
                                  color: light_gray3,
                                  width: 1
                              )
                          )
                        ),
                        child: Consumer<MenuProvider>(
                            builder: (context, menuProvider, child) {
                              return  Text(
                                    menuProvider.translate('mother_no'),    // <다국어> 모돈번호
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                  );
                            }),

                      )
                    ),
                    Expanded(
                    flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          alignment: Alignment.center,
                          height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                        decoration: const BoxDecoration(
                          border: Border(
                          right: BorderSide(
                            color: light_gray3,
                            width: 1
                            ),
                              bottom: BorderSide(
                                  color: light_gray3,
                                  width: 1
                              )
                          )
                        ),
                        child: Text(
                          "${mSowInfoModel.value.pig_coupon}",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                        )
                      )
                    ),
                    Expanded(
                    flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          alignment: Alignment.center,
                          height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                          decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: light_gray3,
                                      width: 1
                                  ),
                                  bottom: BorderSide(
                                      color: light_gray3,
                                      width: 1
                                  )
                              )
                          ),
                          child: Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Text(
                                      menuProvider.translate('breed_no'),   // <다국어> 품종
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                    );
                              })
                      )
                    ),
                    Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        alignment: Alignment.center,
                        height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: light_gray3,
                                  width: 1
                              )
                          )
                        ),
                        child: Text(
                          "${mSowInfoModel.value.pig_kind}",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                        )
                      )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('notch_no'),     // <다국어> 이각번호
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.ear_no}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return  Text(
                                        menuProvider.translate('system_no'),    // <다국어> 계통
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: light_gray3,
                                      width: 1
                                  )
                              )
                            ),
                          child: Text(
                          "${mSowInfoModel.value.pig_line}",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                        )
                      )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('birth'),    // <다국어> 생년월일
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.birth}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('days_age'),     //  <다국어> 생후일령
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.day_age}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('where_purchased'),    // <다국어> 구입처
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.customer_nm}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return  Text(
                                        menuProvider.translate('movein_date'),      // <다국어> 전입일
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child:Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                          "",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                        )
                      )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return  Text(
                                        menuProvider.translate('now_parity'),     // <다국어> 현재산차
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.parity}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('pig_status'),   // <다국어> 현재상태
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                          "${mSowInfoModel.value.pig_status}",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                        )
                      )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('last_work_date'),     // <다국어> 최종작업일
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.last_work_date}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('delivery_due_day'),   // <다국어> 분만예정일
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.delivery_due_date}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('culling_date'),     // <다국어> 도태일자
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.out_date}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('culling_cause'),    // <다국어> 도태원인
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            alignment: Alignment.center,
                            height: language.value == "ko" ? CustomStyle.getHeight(30) : CustomStyle.getHeight(50),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mSowInfoModel.value.out_reason}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                            )
                        )
                    ),
                  ],
                )
                
              ],
            ),
          )
        ],
      ),
      )
    );
  }

  /**
   * 번식이력 영역 Widget
   */
  Widget addidentDetail2Widget() {
    return Obx(() => Container(
      padding: EdgeInsets.only(left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return  Text(
                      menuProvider.translate('breed_info'),   // <다국어> 번식이력
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(
                          language.value == "ko" ? styleFontSize15 : styleFontSize13, Colors.black,font_weight: FontWeight.w800),
                    );
                  }),
              // 산차별 정보를 조회하기 위한 페이지 버튼
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      if(page.value > 0) {
                        page.value--;
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 28,
                    )
                  ),
                  InkWell(
                    onTap: (){
                      if(page.value < (mBreedList.length-1)) {
                        page.value++;
                      }
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 28,
                    )
                  )
                ],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
            decoration: BoxDecoration(
                border: Border.all(color: light_gray3, width: 1)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                        menuProvider.translate('parity'),     // <다국어> 산차
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(
                                            language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                      );
                                }),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].parity : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('mate_date'),    // <다국어> 교배일
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                }),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].mate_date : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('delivery_day'), // <다국어> 분만일
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                }),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].delivery_date : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('pregnant_days'),    // <다국어> 임신일수
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].pregnant_days : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont( language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('tot_count'),  // <다국어> 총산
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].tot_count : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('dead_count'),   // <다국어> 사산
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].dead_count : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('mummy_count'),    // <다국어> 미라
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].mummy_count : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('other'),      // <다국어> 기타
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].selection_count : "0"}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('lactation_count'),    // <다국어> 포유개시두수
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].lactation_count : "0"}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('lactation_days'),   // <다국어> 포유기간
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].lactation_days : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('wean_day'),     // <다국어> 이유일
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    )
                                )
                            ),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].wean_date : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: light_gray3,
                                        width: 1
                                    ),
                                )
                            ),
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return Text(
                                    menuProvider.translate('wean_count'),   // <다국어> 이유두수
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  );
                                })
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                            child: Text(
                              "${mBreedList.isNotEmpty ? mBreedList[page.value].wean_count : ""}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            )
                        )
                    ),
                  ],
                )
                
              ],
            ),
          )
        ],
      ),
      )
    );
  }

  openListDialog(BuildContext context, List<SowModel>? list) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return  StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  title: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: light_gray3,
                                  width: 2
                              )
                          )
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "모돈번호",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "산차",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "현재상태",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize15, Colors.black,font_weight: FontWeight.w800),
                                  )
                              ),
                            ],
                          )
                        ],
                      )),
                  content:  Container(
                    width: double.maxFinite, // 최대 가로 크기 설정
                    height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.5,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true, // 높이를 내용물에 맞추도록 설정
                      itemCount: list?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = list?[index];
                        return InkWell(
                            onTap: (){

                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: light_gray8,
                                            width: 1
                                        )
                                    )
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          "${item?.pig_coupon}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          "${item?.parity}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          "${item?.pig_status}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                        )
                                    )
                                  ],
                                )
                            )
                        );
                      },
                    ),
                  ),
                );
              });
        });
  }

  /**
   * End Widget
   */

  /**
   * Start Function
   */


  Future<void> goToQRPage() async {
    await Navigator.of(context).push(PageAnimationTransition(page: QRPage(code: "accident"), pageAnimationType: RightToLeftFadedTransition()));
  }


  /**
   * 개체관리 Item 상세조회
   */
  Future<void> getSowDetail() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowDetail(mUser.value.access_key, "sow_detail", "K", mUser.value.user_id, mUser.value.last_farm_no,widget.sowModel?.mother_no).then((it) async {
      await pr?.hide();
      ReturnSowDetailMap _response = DioService.dioSowDetailResponse(it);
      logger.i("getSowDetail() Response => ${_response.list_count} || ${_response.sow_info} || ${_response.breed_list}");
      if(_response.sow_info != null) {
        mSowInfoModel.value = _response.sow_info??SowInfoModel();
        mBreedList.value = _response.breed_list??List.empty(growable: true);
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getSowDetail() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getSowList() default Error : => ${obj}");
          break;
      }
    });
  }

  /**
   * End Function
   */

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return WillPopScope(
        onWillPop: () async {
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
                  return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        menuProvider.translate('individual_manager'),     // <다국어> 개체관리
                        softWrap: true,
                        textAlign: TextAlign.start,

                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize12, Colors.white,font_weight: FontWeight.w700)
                      ));
                }),
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    addidentDetail1Widget(),      // 모돈정보 영역
                    addidentDetail2Widget()       // 번식이력 영역
                  ],
                )
            )
          ),
        )
    );
  }
}