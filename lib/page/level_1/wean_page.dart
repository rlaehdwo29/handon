
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/strings.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/page/level_1/level_2/manage_page.dart';
import 'package:handon_project/page/level_1/level_2/qr_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/util.dart';
import 'package:logger/logger.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class WeanPage extends StatefulWidget {


  WeanPage({Key? key}) : super(key:key);

  _WeanPageState createState() => _WeanPageState();
}

class _WeanPageState extends State<WeanPage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();

  final mList = List.empty(growable: true).obs;
  final selectSowList = <SowModel>[].obs;
  final mUser = UserModel().obs;
  final language = "my".obs; // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어

  late TextEditingController sowNumController;
  final List<TextEditingController> weanControllers = []; //포유폐사 Edit List
  final List<FocusNode> weanFocus = [];
  final List<TextEditingController> lactationControllers = []; //이유두수 Edit List
  final List<FocusNode> lactationFocus = [];
  final mCalendarNowDate = DateTime.now().obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  AutoScrollController  scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    sowNumController = TextEditingController();
    selectSowList.value = List.empty(growable: true);
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
      await getWeanList();
      weanControllers.addAll(mList.map((_) => TextEditingController(text: "0")));
      weanFocus.addAll(mList.map((_) => FocusNode()));
      lactationControllers.addAll(mList.map((_) => TextEditingController(text: "0")));
      lactationFocus.addAll(mList.map((_) => FocusNode()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    sowNumController.dispose();
    for (var controller in weanControllers) {
      controller.dispose();
    }
    for(var focus in weanFocus) {
      focus.dispose();
    }
    for (var controller in lactationControllers) {
      controller.dispose();
    }
    for(var focus in lactationFocus) {
      focus.dispose();
    }
  }

  /**
   * Start Widget
   */

  // 모돈번호 검색 Widget
    Widget sowSearchWidget() {
      return  Container(
        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              menuProvider.translate('mother_no'),    // <다국어> 모돈번호
                              style: CustomStyle.CustomFont(
                                  language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            ));
                      }),
                  Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.6,
                      alignment: Alignment.center,
                      height: CustomStyle.getHeight(50.h),
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        controller: sowNumController,
                        maxLines: 1,
                        decoration: sowNumController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
                              borderRadius: BorderRadius.circular(5.h)
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
                              borderRadius: BorderRadius.circular(5.h)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              await getSearchSow();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            icon: Icon(
                              Icons.search,
                              size: 24.h,
                              color: Colors.black,
                            ),
                          ),
                        )
                            : InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
                              borderRadius: BorderRadius.circular(5.h)
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
                              borderRadius: BorderRadius.circular(5.h)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              await getSearchSow();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            icon: Icon(
                              Icons.search,
                              size: 24.h,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onChanged: (value){

                        },
                        maxLength: 50,
                      )
                  ),
                ]),
            InkWell(
              onTap: (){
                goToQRPage();   // QR코드 페이지 이동
              },
              child: const Icon(
                Icons.qr_code,
                size: 36,
              )
            )
          ],
        ),
      );
    }

  Widget sowList() {
    return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      return SizedBox(
                              width: language.value == "ko" ? 110 : 130,
                              child: Text(
                                softWrap: true,
                                menuProvider.translate('wean_due'),
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black),
                              )
                      );
                    }),
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "${menuProvider.translate('total')}",
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      ));
                                }),
                            Text(
                              "${mList.length}",
                              style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                            ),
                            Consumer<MenuProvider>(
                                builder: (context, menuProvider, child) {
                                  return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "${menuProvider.translate('bok')}",
                                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                      ));
                                }),
                          ],
                        )
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('select'),
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      "${selectSowList.length}",
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('bok'),
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
                  flex: 3,
                  child:  Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return Text(
                          menuProvider.translate('mother_no'),
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
                          menuProvider.translate('parity'),
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
                          menuProvider.translate('lactation'),
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
                          menuProvider.translate('lactation_out'),
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
                        menuProvider.translate('wean_count'),
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                      );
                    }),
              )
              ],
            )
          ),
          mList.isNotEmpty ?
          Expanded(
            child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 2,
                            color: Color(0xff08C2FF)
                        )
                    )
                ),
                child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: scrollController,
                itemCount: mList.length,
                itemBuilder: (context, index) {
                  var item = mList[index];
                  return AutoScrollTag (
                      key: ValueKey(index),
                  controller: scrollController,
                  index: index,
                  child: getListView(item,index)
                  );
                }
            )),
          ) : SizedBox(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
              child:Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
      ]
    );
  }

  Widget getListView(SowModel item, int _index) {
    return InkWell(
      onTap: () async {
        if (selectSowList.any((element) => element.mother_no == item.mother_no)) {
          selectSowList.removeWhere((element) => element.mother_no == item.mother_no);
        } else {
          item.index = _index;
          selectSowList.add(item);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10)),
        decoration:  BoxDecoration(
          color: selectSowList.any((element) => element.mother_no == item.mother_no) ? Colors.blue : Colors.white,
          border: const Border(
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
              "${item.pig_coupon}",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${item.parity}",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${item.lactation_count}",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
          Expanded(
            flex: 2,
            child:  Container(
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                height: CustomStyle.getHeight(35),
                alignment: Alignment.center,
                child: TextField(
                  controller: lactationControllers[_index],
                  keyboardType: TextInputType.number,
                  focusNode: lactationFocus[_index],
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(),
                  maxLength: 15,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5) ),
                  ),
                  textAlignVertical: TextAlignVertical.center, // 세로 정렬
                  onChanged: (value){
                    lactationControllers[_index].text = int.parse(value).toString();
                  },
                )
            ),
          ),
          Expanded(
            flex: 2,
            child:  Container(
                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5)),
                height: CustomStyle.getHeight(35),
                alignment: Alignment.center,
                child: TextField(
                controller: weanControllers[_index],
                  keyboardType: TextInputType.number,
                  focusNode: weanFocus[_index],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) =>  lactationFocus[_index].unfocus(),
                  maxLength: 15,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                    counterText: "",
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5) ),
                ),
                  onChanged: (value){
                    weanControllers[_index].text = int.parse(value).toString();
                  },
              )
            ),
          ),
        ],
      )
      )
    );
  }

  Future openCalendarDialog() {
    DateTime? tempSelectedDay = mCalendarNowDate.value;
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
                                            lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                            daysOfWeekHeight: language.value == "ko" ? 32 * MediaQuery.of(context).textScaleFactor : 60 * MediaQuery.of(context).textScaleFactor,
                                            headerStyle: HeaderStyle(
                                              // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                                              formatButtonVisible: false,
                                              // 달력 타이틀을 센터로
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
                                              // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                                              defaultDecoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              // 캘린더의 주말 배경 스타일링
                                              weekendDecoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              // 선택한 날짜 배경 스타일링
                                              selectedDecoration: BoxDecoration(
                                                  color:Colors.white,
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
                                            focusedDay: tempSelectedDay!,
                                            selectedDayPredicate: (day) {
                                              return isSameDay(tempSelectedDay, day);
                                            },

                                            calendarFormat: _calendarFormat,
                                            onDaySelected: (selectedDay, focusedDay) {
                                                setState(() {
                                                  tempSelectedDay = selectedDay;
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
                                              tempSelectedDay = focusedDay;
                                            },
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                mCalendarNowDate.value = tempSelectedDay!;
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
                                                            menuProvider.translate('commit'),
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
                                  child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                        return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              menuProvider.translate('mother_no'),
                                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                            ));
                                      }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                        return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              menuProvider.translate('parity'),
                                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                            ));
                                      }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Consumer<MenuProvider>(
                                      builder: (context, menuProvider, child) {
                                        return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              menuProvider.translate('finish_delivery_day'),
                                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                            ));
                                      }),
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
                              selectSowList.add(item!);
                              int _index = mList.indexWhere((element) => element.mother_no == item.mother_no);
                              weanFocus[_index].requestFocus();
                              scrollController.scrollToIndex(
                                _index,
                                duration: const Duration(milliseconds: 1000),
                                preferPosition: AutoScrollPosition.begin,
                              );

                              Navigator.of(context).pop();
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
                                          "${item?.last_work_date}",
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

  /*
   * 이유 관리 페이지 이동 Function
   */
  Future<void> goToAccident() async {
    await Navigator.of(context).push(PageAnimationTransition(page: ManagePage(code: "wean"), pageAnimationType: RightToLeftFadedTransition()));
  }

  /**
   * QR코드 인식 페이지 이동 Function
   */
  Future<void> goToQRPage() async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: QRPage(code: "wean"), pageAnimationType: RightToLeftFadedTransition()));

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToQRPage() -> ${results["selectItem"]}");
        int _index = mList.indexWhere((element) => element.mother_no == results["selectItem"].mother_no);
        bool isAlreadyAdded = selectSowList.any((item) => item.mother_no == results["selectItem"].mother_no);

        if (_index < 0) {
          Util.toast((context.read<MenuProvider>().translate('msg_not_match_mother_no')));    // <다국어> 일치하는 모돈 번호가 없습니다.
        } else if (isAlreadyAdded) {
          Util.toast(context.read<MenuProvider>().translate('msg_validation'));   // <다국어> 이미 선택된 모돈입니다.
        } else {
          // 중복이 아닌 경우에만 추가
          selectSowList.add(results["selectItem"]);

          scrollController.scrollToIndex(
            _index,
            duration: const Duration(milliseconds: 1000),
            preferPosition: AutoScrollPosition.begin,
          );
        }
      }else{
        await getWeanList();
      }
    }
  }

  /*
   * 이유 List API
   */
  Future<void> getWeanList() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "wean", "K", mUser.value.user_id, mUser.value.last_farm_no,null,null).then((it) async {
      await pr?.hide();
      ReturnSowMap _response = DioService.dioSowResponse(it);
      logger.i("getWeanList() Response => ${_response.list_count} || ${_response.sow_list}");
      if (_response.sow_list!.length > 0) {
        if(mList.length > 0) mList.clear();
        mList.value =_response.sow_list as List<SowModel>;
      } else {
        mList.value = List.empty(growable: true);
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getWeanList() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getWeanList() default Error : => ${obj}");
          break;
      }
    });
  }

  /**
   * 모돈번호 검색 API
   */
  Future<void> getSearchSow() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "wean_search", "K", mUser.value.user_id, mUser.value.last_farm_no,sowNumController.text,null).then((it) async {
      await pr?.hide();
      ReturnSowMap _response = DioService.dioSowResponse(it);
      logger.i("getSearchSow() Response => ${_response.list_count} || ${_response.sow_list}");
      List<SowModel>? sow = _response.sow_list;
      openListDialog(this.context, sow);
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getSearchSow() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getSearchSow() default Error : => ${obj}");
          break;
      }
    });
  }

  /**
   * 이유 저장 Function
   */
  Future<Map<String,dynamic>> saveSow(int _index, SowModel sow) async {
    Logger logger = Logger();
    Map<String,dynamic> result = {};
    try {
      // `sow.index`가 null일 경우 0으로 대체
      final int sowIndex = sow.index ?? 0;
      final int currentIndex = sowIndex - _index;

      // 인덱스 검증
      if (currentIndex < 0 || currentIndex >= weanControllers.length || currentIndex >= lactationControllers.length) {
        logger.e(
          "Invalid index: $currentIndex, "
              "weanControllers length: ${weanControllers.length}, "
              "lactationControllers length: ${lactationControllers.length}",
        );
        result = {"result":false, "message": "모돈번호: ${sow.pig_coupon}\n 잘못된 인덱스입니다."};
      }

      // 로그로 상태 확인
      logger.d(
        "Before API call: "
            "currentIndex: $currentIndex, "
            "weanControllers length: ${weanControllers.length}, "
            "lactationControllers length: ${lactationControllers.length}",
      );

      // 삭제 전 필요한 값 가져오기
      int weanCnt = int.parse(weanControllers[currentIndex].text);
      int lacCnt = int.parse(lactationControllers[currentIndex].text);

      // API 호출
      await DioService.dioClient(header: true).saveSow(
        mUser.value.access_key,
        "wean_insert",
        "K",
        mUser.value.user_id,
        mUser.value.last_farm_no,
        Util.getDate(mCalendarNowDate.value),
        sow.mother_no,
        wean_count: weanCnt,
        lactation_dead_count: lacCnt,
      ).then((it) async {
        // 응답 처리
        ReturnMap _response = DioService.dioResponse(it);
        logger.i("saveSow() Response => ${_response.error}");

        // 성공 여부 확인
        if (_response.error?["error_code"] == null || _response.error?["error_code"] == "") {

          // 삭제 작업
          try {
            // 삭제 전 리스트 길이 확인
            logger.d(
              "Before deletion: "
                  "weanControllers length: ${weanControllers.length}, "
                  "lactationControllers length: ${lactationControllers.length}",
            );

            weanControllers.removeAt(currentIndex);
            lactationControllers.removeAt(currentIndex);

            // 삭제 후 리스트 길이 확인
            logger.d(
              "After deletion: "
                  "weanControllers length: ${weanControllers.length}, "
                  "lactationControllers length: ${lactationControllers.length}",
            );

            // 리스트 갱신
            await getWeanList();
            result = {"result":true, "message": ""};
            setState(() {});
          } catch (deleteError) {
            logger.e("Error during deletion: $deleteError");
            //Util.toast(context.read<MenuProvider>().translate('msg_error_delete_wean'));
            result = {"result":false, "message": "모돈번호: ${sow.pig_coupon}\n(${_response.error?["error_code"]}) ${context.read<MenuProvider>().translate('msg_error_delete_wean')}"};
          }
        } else {
          result = {"result":false, "message": "모돈번호: ${sow.pig_coupon}\n(${_response.error?["error_code"]}) ${_response.error?["message"]}"};
          //Util.toast("${_response.error?["error_code"]} : ${_response.error?["message"]}");
        }
      }).catchError((Object obj) async {
        result = {"result":false, "message": "모돈번호: ${sow.pig_coupon}:\n${context.read<MenuProvider>().translate('msg_server_connection_issue')}"};
        //Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
        // 오류 처리
        switch (obj.runtimeType) {
          case DioError:
            final res = (obj as DioError).response;
            logger.e("saveSow() error : ${res?.statusCode} -> ${res?.statusMessage}");
            break;
          default:
            logger.e("saveSow() default Error : => $obj");
            break;
        }
      });
    } catch (e) {
      logger.e("Unexpected error in saveSow(): $e");
      //Util.toast(context.read<MenuProvider>().translate('msg_error_save_wean'));
      result = {"result":false, "message": "모돈번호: ${sow.pig_coupon}\n${context.read<MenuProvider>().translate('msg_error_save_wean')}"};
    }
    return result;
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
        resizeToAvoidBottomInset: true,
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
                      menuProvider.translate('wean_manager'),   // <다국어> 이유관리
                      style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
                    ));
              }),
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
                child: Column(
              children: [
                sowSearchWidget(),
                SizedBox(
                  height:  MediaQuery.sizeOf(context).height * 0.63,
                  child: sowList()
                ),
               Container(
                        margin: EdgeInsets.only(left: CustomStyle.getWidth(15),top: CustomStyle.getHeight(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    right: CustomStyle.getWidth(5)),
                                child: Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                      return Obx(() => Text(
                                            menuProvider.translate('wean_date'),  // <다국어> 이유일자
                                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black),
                                          ));
                                    }),
                            ),
                            InkWell(
                                onTap: () {
                                  openCalendarDialog();
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: CustomStyle.getHeight(5),
                                        horizontal: CustomStyle.getWidth(30)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1)
                                    ),
                                    child: Obx(() => Text(
                                      "${Util.getDate(mCalendarNowDate.value)}",
                                      style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                    ))
                                )
                            )
                          ],
                        )
                    )
              ],
            ));
          }),
        ),
        // 화면 Footer Widget
        bottomNavigationBar: SizedBox(
            height: CustomStyle.getHeight(60.0.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                            height: CustomStyle.getHeight(60.0.h),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    bottom:10,
                                    child: InkWell(
                                      onTap: () async {

                                        if (selectSowList.isNotEmpty) {
                                          bool _isLoading = false;
                                          double _progress = 0.0;
                                          int total = selectSowList.length;
                                          int count = 0;
                                          int completed = 0;
                                          int failed = 0;
                                          String failReason = "";

                                          // Progress 상태를 관리하는 변수
                                          setState(() {
                                            _isLoading = true;
                                            _progress = 0;
                                          });

                                          // 선택된 이유 리스트들을 순차적으로 저장
                                          await Future.forEach(selectSowList, (item) async {
                                            Map<String,dynamic> result = await saveSow(count,item);
                                            if(result["result"] == true) {
                                              completed++;
                                            }else{
                                              failed++;
                                              failReason += "${result["message"]}\n";
                                            }
                                            count++;
                                            // Progress 상태 업데이트
                                            setState(() {
                                              _progress = count / total;
                                            });
                                          });

                                          setState(() {
                                            _isLoading = false;
                                            if(failed > 0) {
                                              openOkBox(context,"Save Failed!!\n\n${failReason}",context.read<MenuProvider>().translate('yes'), () {
                                                Navigator.of(context).pop(false);
                                              });
                                              if(completed > 0) {
                                                Util.toast(context.read<MenuProvider>().translate('msg_success_save_wean'));  // <다국어> 이유가 저장되었습니다.
                                              }
                                            }else{
                                              Util.toast(context.read<MenuProvider>().translate('msg_success_save_wean'));    //<다국어> 이유가 저장되었습니다.
                                            }
                                            selectSowList.value = List.empty(growable: true);
                                          });
                                        } else {
                                          Util.toast((context.read<MenuProvider>().translate('msg_select_save_wean'))); // <다국어> 이유가 저장되었습니다.
                                        }
                                      },
                                        child: Container(
                                          width:  MediaQuery.sizeOf(context).width * 0.5,
                                          height: CustomStyle.getHeight(50.0.h),
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(color: main_color),
                                          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20)),
                                        child: Consumer<MenuProvider>(
                                            builder: (context, menuProvider, child) {
                                              return Obx(() => Text(
                                                    menuProvider.translate('wean_save'),    // <다국어> 이유저장
                                                    style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize12, Colors.white),
                                                  ));
                                            }),
                                      )
                                    )
                                  ),
                                  Positioned(
                                      bottom:10,
                                      right: 10,
                                      child: InkWell(
                                        onTap: (){
                                          goToAccident(); // 이유기록 페이지 이동
                                        },
                                          child: const Icon(
                                            Icons.list_alt,
                                            size: 48,
                                            color: main_color,
                                          )
                                      )
                                  ),
                                ]
                            )
                    )
                ),
              ],
            )),
      )
    );
  }
}