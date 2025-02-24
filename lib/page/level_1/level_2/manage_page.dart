
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/model/work_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/util.dart';
import 'package:logger/logger.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

// ignore: must_be_immutable
class ManagePage extends StatefulWidget {

  String? code;     // mate = 교배, delivery = 분만, wean = 이유, accident = 임신사고, out = 도폐사

  ManagePage({Key? key,required this.code}) : super(key:key);

  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final mList = List.empty(growable: true).obs;   // Code별 기록 List
  final mUser = UserModel().obs;
  final language = "my".obs;  // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어

  // 일자 선택 변수
  DateTime mCalendarNowDate = DateTime.now();
  final mCalendarStartDate = DateTime.now().obs;
  final mCalendarEndDate = DateTime.now().obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  // code work
  final p_tot_count = 0.obs;
  final p_real_count = 0.obs;
  final p_lactation_count = 0.obs;
  final p_wean_count = 0.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
      await getWorkList();     // 분만 리스트 가져오기 API
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * Start Widget
   */

  //  날짜 조회 Widget
    Widget accidentSearchWidget() {
      return  Container(
        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10),right: CustomStyle.getWidth(10), left: CustomStyle.getWidth(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                 child: Image.asset(
                   widget.code == "mate" ? "assets/image/img_mating.png" : widget.code == "delivery" ? "assets/image/img_farrowing.png" : widget.code == "wean"? "assets/image/img_weaning.png" : widget.code == "accident" ? "assets/image/img_prcheck.png" : widget.code == "out" ? "assets/image/img_culling.png" : "assets/image/img_sowcard.png",
                   width: CustomStyle.getWidth(55.0),
                   height: CustomStyle.getHeight(45.0),
                   color: styleBaseCol1,
                 )
                ),
                Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            // <다국어> 교배기록, <다국어> 분만기록, <다국어> 이유기록, <다국어> 임신사고기록, <다국어> 도폐기록, <다국어> 개체 기록
                            widget.code == "mate" ? menuProvider.translate('mate_record') : widget.code == "delivery" ? menuProvider.translate('delivery_record') : widget.code == "wean" ? menuProvider.translate('wean_record')  : widget.code == "accident" ? menuProvider.translate('accident_record') : widget.code == "out" ? menuProvider.translate('out_record') :  "개체기록",
                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize12, Colors.black),
                          ));
                    }),
              ],
            )
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                              // <다국어> 교배일자, <다국어> 분만예정일, <다국어> 이유일자, <다국어> 분만성적일, <다국어> 도폐일
                                  widget.code == "mate" ? menuProvider.translate('mate_day') : widget.code == "delivery" ? menuProvider.translate('delivery_date') : widget.code == "wean" ? menuProvider.translate('wean_date')  : widget.code == "accident" ? menuProvider.translate('accident_date') : widget.code == "out" ? menuProvider.translate('out_date') :  "",
                                  softWrap: true,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 5,
                      child: InkWell(
                        onTap: (){
                          openCalendarDialog();   // 날짜 선택 Dialod Widget
                        },
                          child: Container(
                              height: 35.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black,width: 1)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mCalendarStartDate.value == null?"-":"${mCalendarStartDate.value.year}-${mCalendarStartDate.value.month}-${mCalendarStartDate.value.day}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                            ),
                            Text(
                              " ~ ",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize18, Colors.black,font_weight: FontWeight.w800),
                            ),
                            Text(
                              mCalendarEndDate.value == null?"-":"${mCalendarEndDate.value.year}-${mCalendarEndDate.value.month}-${mCalendarEndDate.value.day}",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                            )
                          ],
                        )
                      )
                    )
                  ),
                  Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          await getWorkList();  // 분만 리스트 가져오기 API
                        },
                          child: Container(
                            height: 35.h,
                            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                            alignment: Alignment.center,
                            color: main_color,
                            child: Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        menuProvider.translate('search'),       // <다국어> 조회
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.white),
                                      ));
                                }),
                          )
                      )
                  ),
                ],
              )
            )
          ]),
      );
    }

    // 교배 기록 List
  Widget mateList() {
    return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),      // <다국어> 총
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${mList.length} ",  // 리스트의 총 개수
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('do'),       // <다국어> 두
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
            decoration: const BoxDecoration(
              color:  Color(0xff08C2FF),
              border: Border(
               top: BorderSide(width: 2,color: light_gray3),
               bottom: BorderSide(width: 2,color: light_gray3)
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child:  Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              menuProvider.translate('mother_no'),      // <다국어> 모돈번호
                              maxLines: 1,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            ));
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              menuProvider.translate('parity'),         // <다국어> 산차
                              maxLines: 1,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            ));
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              menuProvider.translate('mate_date'),      // <다국어> 교배일
                              maxLines: 1,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            ));
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              menuProvider.translate('mate_state'),       // <다국어> 교배구분
                              maxLines: 1,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            ));
                      }),
                ),
              ],
            )
          ),
          mList.isNotEmpty ?
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: mList.length,
                itemBuilder: (context, index) {
                  var item = mList[index];
                  return getMateListView(item);      // 교배 List Item Widget
                }
            ),
          ) : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child:  Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                  return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                  menuProvider.translate('no_search'),        // <다국어> 검색된 목록이 없습니다
                  style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                  ));
                }),
            ),
          )
      ]
    );
  }

  // 분만 기록 List
  Widget deliveryList() {
    return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(language.value == "ko" ? 10 : 0)) ,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return language.value != "ko" ?
                          SizedBox(
                              width: 40,
                              child: Text(
                                menuProvider.translate('total'),        // <다국어> 총
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('total'),        // <다국어> 총
                            softWrap: true,
                            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                          );
                        }),
                    Text(
                      " ${mList.length} ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return Text(
                                "${menuProvider.translate('bok')}",     // <다국어> 복
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize9, Colors.black),
                              );
                        }),
                    Text(
                      " / ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return language.value != "ko" ?
                          SizedBox(
                              width: 50,
                              child: Text(
                                menuProvider.translate('tot_count'),      // <다국어> 총산
                                softWrap: true,
                                maxLines: 1,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ):
                          Text(
                            menuProvider.translate('tot_count'),        // <다국어> 총산
                            softWrap: true,
                            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                          );
                        }),
                    Text(
                      " ${p_tot_count.value} / ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return  language.value != "ko" ?
                          SizedBox(
                              width: 50,
                              child: Text(
                                menuProvider.translate('real_count'),     // <다국어> 실산
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('real_count'),       // <다국어> 실산
                            softWrap: true,
                            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                          );
                        }),
                    Text(
                      " ${p_real_count.value} / ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return language.value != "ko" ?
                          SizedBox(
                              width: 35,
                              child: Text(
                                menuProvider.translate('lactation'),      // <다국어> 포유개시
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('lactation'),          // <다국어> 포유개시
                            softWrap: true,
                            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                          );
                        }),
                    Text(
                      " ${p_lactation_count.value}",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              decoration: const BoxDecoration(
                color:  Color(0xff08C2FF),
                border: Border(
                    top: BorderSide(width: 2,color: light_gray3),
                    bottom: BorderSide(width: 2,color: light_gray3)
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('mother_no'),          // <다국어> 모돈번호
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          })
                      ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('parity'),           // <다국어> 산차
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          })
                      ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                        child: Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return Text(
                            menuProvider.translate('tot_count'),              // <다국어> 총산
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                          );
                        })
                      ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('delivery_day'),       // <다국어> 분만일
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          })
                      ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('real_count'),         // <다국어> 실산
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          })
                      ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                          child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('lactation'),          // <다국어> 포유개시
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          })
                      ),
                  ),
                ],
              )
          ),
          mList.isNotEmpty ?
                Expanded(
                child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: mList.length,
                itemBuilder: (context, index) {
                      var item = mList[index];
                      return getDeliveryListView(item);   // 분만 List Item Widget
                    })
          )
              : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('no_search'),          // <다국어> 검색된 목록이 없습니다
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

  //  이유 기록 List
  Widget weanList() {
    return Column(
        children: [
          Container(
            margin: language.value == "ko" ? EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)): EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),      // <다국어> 총
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${mList.length} ",   // 총 검색된 List 개수
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('bok'),    // <다국어> 복
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " / ",
                      style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('lactation'),    // <다국어> 포유개시
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${p_lactation_count.value} / ",   // 총 포유개시 개수
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('wean_child'),     // <다국어> 이유자돈
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${p_wean_count.value}",     // 총 이유자돈 개수
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
              decoration: const BoxDecoration(
                color:  Color(0xff08C2FF),
                border: Border(
                    top: BorderSide(width: 2,color: light_gray3),
                    bottom: BorderSide(width: 2,color: light_gray3)
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 3,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('mother_no'),      // <다국어> 이유자돈
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child:Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('parity'),       // <다국어> 산차
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 3,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('wean_day'),     // <다국어> 이유일
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                              menuProvider.translate('lactation_count'),    // <다국어> 포유개시두수
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                              menuProvider.translate('wean_count'),     // <다국어> 이유두수
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                            );
                          }),
                  ),
                ],
              )
          ),
          mList.isNotEmpty ?
            Expanded(
            child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: mList.length,
            itemBuilder: (context, index) {
                      var item = mList[index];
                      return getWeanListView(item);   //  이유 List Item Widget
                    })
            )
              : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('no_search'),        // <다국어> 검색된 목록이 없습니다
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

  // 도폐사 List Widget
  Widget outList() {
    return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),      // <다국어> 총
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${mList.length} ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('do'),     // <다국어> 두
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                  ],
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
              decoration: const BoxDecoration(
                color:  Color(0xff08C2FF),
                border: Border(
                    top: BorderSide(width: 2,color: light_gray3),
                    bottom: BorderSide(width: 2,color: light_gray3)
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Expanded(
                      flex: 2,
                      child:  Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('mother_no'),      // <다국어> 모돈번호
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('out_day'),      // <다국어> 도폐사일
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 1,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('finish_parity'),      // <다국어> 최종산차
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('out_state'),        // <다국어> 도폐사 구분
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('out_reason'),       // <다국어> 도폐사 원인
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                ],
              )
          ),
          mList.isNotEmpty ?
            Expanded(
            child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: mList.length,
            itemBuilder: (context, index) {
                      var item = mList[index];
                      return getOutListView(item);    //  도폐사 List Item Widget
                    })
          )
              : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('no_search'),        // <다국어> 검색된 목록이 없습니다
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

  // 임신사고 List Widget
  Widget accidentList() {
    return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),        // <다국어> 총
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${mList.length} ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('do'),       // <다국어> 두
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                  ],
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
              decoration: const BoxDecoration(
                color:  Color(0xff08C2FF),
                border: Border(
                    top: BorderSide(width: 2,color: light_gray3),
                    bottom: BorderSide(width: 2,color: light_gray3)
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child:  Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  menuProvider.translate('mother_no'),        // <다국어> 모돈번호
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                ));
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child:  Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  menuProvider.translate('parity'),         // <다국어> 산차
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                ));
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  menuProvider.translate('accident_date'),    // <다국어> 임신사고일
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                ));
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('accident_reason'),    // <다국어> 임신사고원인
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                );
                          }),
                  ),
                ],
              )
          ),
          mList.isNotEmpty ?
              Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: mList.length,
                itemBuilder: (context, index) {
                      var item = mList[index];
                      return getAccidentListView(item); // 임신사고 List Item Widget
                    }
                )
          )
              : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('no_search'),      // <다국어> 검색된 목록이 없습니다
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

  // 교배 List Item Widget
  Widget getMateListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: light_gray3,
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "${item.pig_coupon}",       // 모돈번호
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.parity}",     // 산차
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.mate_date}",       // 교배일
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.repeat_yn == "Y" ? "재교배" : item.repeat_yn == "N" ? "정상" : "없음"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
          ],
        )
    );
  }

  // 분만 List Item Widget
  Widget getDeliveryListView(WorkModel item) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: light_gray3,
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.pig_coupon}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.parity}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.tot_count}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.delivery_date??"-"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.real_count??0}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border:Border(
                            right: BorderSide(
                                color: light_gray3,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.lactation_count}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
              )
            ),
          ],
        )
    );
  }

  // 이유 List Item Widget
  Widget getWeanListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: light_gray3,
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 3,
                child: Text(
                  "${item.pig_coupon}",   // 모돈번호
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.parity}",   // 산차
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 3,
                child: Text(
                  "${item.wean_date??"-"}",   // 이유일
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.lactation_count??0}",   // 포유개시 두수
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.wean_count??0}",    //이유두수
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
          ],
        )
    );
  }

  // 도폐사 List Item Widget
  Widget getOutListView(WorkModel item) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: light_gray3,
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: styleGreyCol2,
                        width: 1
                      )
                    )
                  ),
                    child: Text(
                  "${item.pig_coupon}",   // 모돈번호
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
                )
            ),
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: styleGreyCol2,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.out_date}",   // 도폐사일
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                ))
            ),
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: styleGreyCol2,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.parity}",   // 최종산차
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                ))
            ),
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: styleGreyCol2,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.out_gubun}",    //도폐사 구분
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                ))
            ),
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: styleGreyCol2,
                                width: 1
                            )
                        )
                    ),
                    child: Text(
                  "${item.out_reason}",   // 도폐사 원인
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize11, Colors.black),
                ))
            ),
          ],
        )
    );
  }

  // 임신사고 List Item Widget
  Widget getAccidentListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: light_gray3,
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  "${item.pig_coupon}",     // 모돈번호
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.parity??"-"}",      // 산차
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.accident_date??"-"}", // 임신사고일
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.prg_acc??"-"}",   // 임신사고원인
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
          ],
        )
    );
  }

  /**
   * 기록일 날짝 검색 Widget
   */
  Future openCalendarDialog() {
    mCalendarNowDate = DateTime.now();
    DateTime? tempSelectedDay;
    DateTime? tempRangeStart = mCalendarStartDate.value;
    DateTime? tempRangeEnd = mCalendarEndDate.value;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      barrierLabel: "날짜 직접설정",
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(15), topEnd: Radius.circular(15)),
          side: BorderSide(color: Color(0xffEDEEF0), width: 1)
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState)
            {
              return FractionallySizedBox(
                  widthFactor: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width > 700 ? 1.5 : 1.0,
                  heightFactor: 0.7,
                  child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(
                          horizontal: CustomStyle.getWidth(15)),
                      padding: EdgeInsets.only(right: CustomStyle.getWidth(10),
                          left: CustomStyle.getWidth(10),
                          top: CustomStyle.getHeight(10)),
                      decoration: const BoxDecoration(
                          color: Colors.white
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                                child: SizedBox(
                                    width: MediaQueryData.fromView(WidgetsBinding.instance.window).size.width,
                                    height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.65,
                                    child: Column(
                                        children: [
                                          TableCalendar(
                                            rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) : CustomStyle.getHeight(45.h),
                                            locale: language.value == "ko" ? 'ko_KR' : language.value == "ne" ? "ne_NE" : language.value == "my" ? "my_MY" : "km_KM",
                                            firstDay: DateTime.utc(2010, 1, 1),
                                            lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day), // '오늘'까지만 날짜를 선택 할 수 있게 설정. 다음날부턴 선택이 되지 않아야함.
                                            daysOfWeekHeight: language.value == "ko" ? 32 * MediaQuery.of(context).textScaleFactor : 60 * MediaQuery.of(context).textScaleFactor,
                                            headerStyle: HeaderStyle(
                                              // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (2주단위 버튼)
                                              formatButtonVisible: false,
                                              // 달력 타이틀 센터
                                              titleCentered: true,
                                              // 말 그대로 타이틀 텍스트 스타일링
                                              titleTextStyle:
                                              CustomStyle.CustomFont(
                                                  styleFontSize16, Colors.black,
                                                  font_weight: FontWeight.w700
                                              ),
                                              rightChevronIcon: Icon(
                                                  Icons.chevron_right, size: 26.h),
                                              leftChevronIcon: Icon(
                                                  Icons.chevron_left, size: 26.h),
                                            ),
                                            calendarStyle: CalendarStyle(
                                              tablePadding: EdgeInsets.symmetric(
                                                  vertical: CustomStyle.getHeight(10.h),
                                                  horizontal: CustomStyle.getWidth(5.w)
                                              ),
                                              outsideTextStyle: CustomStyle.CustomFont(styleFontSize13, line),
                                              // 오늘 날짜에 하이라이팅의 유무
                                              isTodayHighlighted: false,
                                              // 캘린더의 평일 배경 스타일링(default 평일)
                                              defaultDecoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              // 캘린더의 주말 배경 스타일링
                                              weekendDecoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              // 선택한 날짜 배경 스타일링
                                              selectedDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: main_color, width: 1.w)
                                              ),
                                              defaultTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.black, font_weight: FontWeight.w600),
                                              weekendTextStyle: CustomStyle.CustomFont(styleFontSize14, Colors.red, font_weight: FontWeight.w600),
                                              selectedTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),
                                              // range 크기 조절
                                              rangeHighlightScale: 1.0,

                                              // range 색상 조정
                                              rangeHighlightColor: const Color(0xFFDFE8F4),

                                              // rangeStartDay 글자 조정
                                              rangeStartTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),

                                              // rangeStartDay 모양 조정
                                              rangeStartDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.black, width: 1.w)
                                              ),

                                              // rangeEndDay 글자 조정
                                              rangeEndTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black, font_weight: FontWeight.w600),

                                              // rangeEndDay 모양 조정
                                              rangeEndDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.black, width: 1.w)
                                              ),

                                              // startDay, endDay 사이의 글자 조정
                                              withinRangeTextStyle: CustomStyle.CustomFont(styleFontSize16, Colors.black),

                                              // startDay, endDay 사이의 모양 조정
                                              withinRangeDecoration: const BoxDecoration(),
                                            ),
                                            focusedDay: mCalendarNowDate,
                                            selectedDayPredicate: (day) {
                                              return isSameDay(tempSelectedDay, day);
                                            },
                                            rangeStartDay: tempRangeStart,
                                            rangeEndDay: tempRangeEnd,
                                            calendarFormat: _calendarFormat,
                                            rangeSelectionMode: _rangeSelectionMode,
                                            onDaySelected: (selectedDay, focusedDay) {
                                                if (!isSameDay(tempSelectedDay, selectedDay)) {
                                                  setState(() {
                                                    tempSelectedDay = selectedDay;
                                                    mCalendarNowDate = focusedDay;
                                                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                                  });
                                                }
                                            },
                                            onRangeSelected: (start, end, focusedDay) {
                                              setState(() {
                                                tempSelectedDay = start;
                                                mCalendarNowDate = focusedDay;
                                                tempRangeStart = start;
                                                tempRangeEnd = end;
                                                _rangeSelectionMode = RangeSelectionMode.toggledOn;
                                              });
                                            },

                                            onFormatChanged: (format) {
                                              if (_calendarFormat != format) {
                                                setState(() {
                                                  _calendarFormat = format;
                                                });
                                              }
                                            },
                                            onPageChanged: (focusedDay) {
                                              mCalendarNowDate = focusedDay;
                                            },
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                mCalendarStartDate.value = tempRangeStart!;
                                                mCalendarEndDate.value = tempRangeEnd??tempRangeStart!;
                                                Navigator.of(context).pop(false);
                                              },
                                              child: Center(
                                                  child: Container(

                                                    height: CustomStyle.getHeight(50),
                                                    alignment: Alignment.center,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: CustomStyle.getHeight(5)),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(50),
                                                        color: main_color),
                                                    child: Consumer<MenuProvider>(
                                                        builder: (context, menuProvider, child) {
                                                          return Obx(() => Text(
                                                            menuProvider.translate('commit'),     // <다국어> 적용
                                                            softWrap: true,
                                                            textAlign: TextAlign.center,
                                                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize12, Colors.white),
                                                          )
                                                          );
                                                        })
                                                  )
                                              )
                                          )
                                        ]
                                    )
                                )
                            )
                          ]
                      )
                  )
              );
            });
      },
    );
  }

  /**
   * End Widget
   */



  /**
   * Start Function
   */

  // 분만 리스트 가져오기 API
  Future<void> getWorkList() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getWorkList(mUser.value.access_key, widget.code, "K", mUser.value.user_id, mUser.value.last_farm_no,Util.getDate(mCalendarStartDate.value),Util.getDate(mCalendarEndDate.value)).then((it) async {
      await pr?.hide();
      ReturnWorkMap _response = DioService.dioWorkResponse(it);
      logger.i("getWorkList() Response => ${_response.list_count} || ${_response.work_list}");
      if (_response.work_list!.length > 0) {
        if(mList.length > 0) mList.clear();
        mList.value =_response.work_list as List<WorkModel>;
        p_tot_count.value = _response.p_tot_count??0;
        p_real_count.value = _response.p_real_count??0;
        p_lactation_count.value = _response.p_lactation_count??0;
        p_wean_count.value = _response.p_wean_count??0;
      } else {
        mList.value = List.empty(growable: true);
        p_tot_count.value = 0;
        p_real_count.value = 0;
        p_lactation_count.value = 0;
        p_wean_count.value = 0;
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));        // <다국어> 서버연결에 문제가 있습니다.
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getWorkList() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getWorkList() default Error : => ${obj}");
          break;
      }
    });
  }

  int parseIntDate(String date) {
    return int.parse(Util.mergeDate(date));
  }

  int parseIntDate2(String date) {
    return int.parse(Util.mergeAllDate(date));
  }

  int parseIntTime(String time){
    return int.parse(Util.mergeTime(time));
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
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: main_color,
          toolbarHeight: 50.h,
          automaticallyImplyLeading: false,
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
                      widget.code == "mate" ? menuProvider.translate('mate_manager') : widget.code == "delivery" ? menuProvider.translate('work_manager') : widget.code == "wean" ? menuProvider.translate('wean_manager')  : widget.code == "accident" ? menuProvider.translate('accident_manager') : widget.code == "out" ? menuProvider.translate('out_manager') :  menuProvider.translate('individual_manager'),
                      style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                    ));
              }),
        ),
        body: SafeArea(
          child: Obx(() {
            return Column(
              children: [
                Expanded(
                    flex: 2,
                    child: accidentSearchWidget()   // 각 페이지별 조회 일자를 설정하는 날짜 Widget
                ),
                Expanded(
                    flex: 8,
                    // 이전 화면에서 Return 받은 code값으로 리스트를 호출함.
                    child: widget.code == "mate" ? mateList()           // 교배 기록 List
                        : widget.code == "delivery" ? deliveryList()    // 분만 기록 List
                        : widget.code == "wean" ? weanList()            // 이유 기록 List
                        : widget.code == "accident" ? accidentList()    // 임신사고 기록 List
                        : widget.code == "out" ? outList()              // 도폐사 기록 List
                        : outList()
                ),
              ],
            );
          }),
        ),
      )
    );
  }
}