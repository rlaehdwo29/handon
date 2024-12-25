
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/code_model.dart';
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

class DeadPage extends StatefulWidget {

  DeadPage({Key? key}) : super(key:key);

  _DeadPageState createState() => _DeadPageState();
}

class _DeadPageState extends State<DeadPage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();
  final dropDownKey = GlobalKey<DropdownSearchState>();

  final mList = List.empty(growable: true).obs;
  final mUser = UserModel().obs;
  final selectSowModel = SowModel().obs;

  late TextEditingController motherNumController;
  final mCalendarNowDate = DateTime.now().obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final total_cnt = "0".obs;
  final laction_cnt = "0".obs;
  final dead_code = List.empty(growable: true).obs;
  final dead_reason_code = List.empty(growable: true).obs;
  final select_dead_code = CodeModel().obs;
  final select_dead_reason_code = CodeModel().obs;
  AutoScrollController  scrollController = AutoScrollController();
  final language = "my".obs;

  @override
  void initState() {
    super.initState();
    motherNumController = TextEditingController();
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
      await getSowList();
      select_dead_code.value = CodeModel();
      select_dead_reason_code.value = CodeModel();
      await getCode("BREED_GBN_D");
      await getCode("BREED_REASON");
    });
  }

  @override
  void dispose() {
    super.dispose();
    motherNumController.dispose();
  }

  /**
   * Start Widget
   */

  // 모돈번호 검색 Widget
    Widget workSearchWidget() {
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
                              menuProvider.translate('mother_no'),
                              style: CustomStyle.CustomFont(
                                  language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                            ));
                      }),
                  Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(5),right: CustomStyle.getWidth(5)),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.6,
                      height: CustomStyle.getHeight(50.h),
                      alignment: Alignment.center,
                      child: TextField(
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        controller: motherNumController,
                        maxLines: 1,
                        decoration: motherNumController.text.isNotEmpty
                            ? InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5),vertical: CustomStyle.getHeight(10.h)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
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
                          ),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: CustomStyle.getWidth(1)),
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
                  goToQRPage();
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

    // List
  Widget workList() {
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
                            menuProvider.translate('mother_list'),
                            softWrap: true,
                            style: CustomStyle.CustomFont(
                                language.value == "ko" ? styleFontSize16 : styleFontSize12, Colors.black),
                          ));
                    }),
                Row(
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),
                                style: CustomStyle.CustomFont(
                                    language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
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
                                menuProvider.translate('do'),
                                style: CustomStyle.CustomFont(
                                    language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
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
              color: Color(0xff08C2FF),
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
                  child: Consumer<MenuProvider>(
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
                          menuProvider.translate('pig_status'),
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
                          menuProvider.translate('last_work_date'),
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
            ),
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
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
      ]
    );
  }

  Widget getListView(SowModel item,int _index) {
    return InkWell(
      onTap: (){
        if(selectSowModel.value.mother_no == null) {
          selectSowModel.value = item;
          select_dead_code.value = dead_code[0];
          select_dead_reason_code.value = dead_reason_code[0];
        }else{
          selectSowModel.value = SowModel();
          select_dead_code.value = dead_code[0];
          select_dead_reason_code.value = dead_reason_code[0];
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration:  BoxDecoration(
          color: selectSowModel.value.mother_no == item.mother_no ? Colors.blue : Colors.white,
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
            flex: 2,
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
              "${item.pig_status??"-"}",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${item.last_work_date??"-"}",
              textAlign: TextAlign.center,
            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
        ],
      )
      )
    );
  }

  Widget workWriteWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(right: CustomStyle.getWidth(15),left: CustomStyle.getWidth(15),bottom: CustomStyle.getHeight(10)),
          child: Row(
            children: [
              Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          menuProvider.translate('write_out'),
                          style: CustomStyle.CustomFont(
                              language.value == "ko" ? styleFontSize18 : styleFontSize14, Colors.black),
                        ));
                  }),
              Container(
                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                child: Text(
                  "${selectSowModel.value.pig_coupon??"-"}",
                  style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                ),
              )
            ],
          )
        ),
        Container(
          child: Column(
            children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Consumer<MenuProvider>(
                              builder: (context, menuProvider, child) {
                                return Obx(() => SizedBox(
                                    width: CustomStyle.getWidth(120),
                                    child: Text(
                                      menuProvider.translate('out_state'),
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                    )
                                  )
                                );
                              }),
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                              width: CustomStyle.getWidth(150.w),
                              height: CustomStyle.getHeight(40),
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(10)),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black,width: 1),
                                  borderRadius:BorderRadius.circular(5),
                                  color: Colors.white
                              ),
                              child: DropdownButton<CodeModel>(
                                value: select_dead_code.value,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: dead_code.map((e) => DropdownMenuItem<CodeModel>(
                                  value: e, // 선택 시 onChanged 를 통해 반환할 value
                                  child: Text(e.cd_nm,style: CustomStyle.CustomFont(styleFontSize14, Colors.black),),
                                ))
                                    .toList(),
                                onChanged: (CodeModel? newValue) { // items 의 DropdownMenuItem 의 value 반환
                                  setState(() {
                                    select_dead_code.value = newValue??CodeModel();
                                  });
                                },
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Consumer<MenuProvider>(
                            builder: (context, menuProvider, child) {
                              return Obx(() => SizedBox(
                                  width: CustomStyle.getWidth(120),
                                  child: Text(
                                    menuProvider.translate('out_reason'),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                  )));
                            }),
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                            height: CustomStyle.getHeight(40),
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5), horizontal: CustomStyle.getWidth(10)),
                            width: CustomStyle.getWidth(150.w),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 1),
                                borderRadius:BorderRadius.circular(5),
                                color: Colors.white
                            ),
                            child: DropdownButton<CodeModel>(
                              value: select_dead_reason_code.value,
                              underline: const SizedBox.shrink(),
                              isExpanded: true,
                              items: dead_reason_code.map((e) => DropdownMenuItem<CodeModel>(
                                value: e, // 선택 시 onChanged 를 통해 반환할 value
                                child: Text(e.cd_nm,style: CustomStyle.CustomFont(styleFontSize14, Colors.black)),
                              ))
                                  .toList(),
                              onChanged: (CodeModel? newValue) { // items 의 DropdownMenuItem 의 value 반환
                                setState(() {
                                  select_dead_reason_code.value = newValue??CodeModel();
                                });
                              },
                            )
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
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
                                              menuProvider.translate('pig_status'),
                                              style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                            ));
                                      })
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
                              selectSowModel.value = item??SowModel();
                              select_dead_code.value = dead_code[0];
                              select_dead_reason_code.value = dead_reason_code[0];
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

  Future<void> goToAccident() async {
    await Navigator.of(context).push(PageAnimationTransition(page: ManagePage(code: "out",), pageAnimationType: RightToLeftFadedTransition()));
  }


  Future<void> goToQRPage() async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: QRPage(code: "out"), pageAnimationType: RightToLeftFadedTransition()));

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        print("goToQRPage() -> ${results["selectItem"]}");
        int _index = mList.indexWhere((element) => element.mother_no == results["selectItem"].mother_no);
        if(_index < 0) {
          Util.toast((context.read<MenuProvider>().translate('msg_not_match_mother_no')));
        }else {
          selectSowModel.value = results["selectItem"];
          scrollController.scrollToIndex(
            _index,
            duration: const Duration(milliseconds: 1000),
            preferPosition: AutoScrollPosition.begin,
          );
        }
      }
    }
  }

  void initEdit() {
    total_cnt.value = "0";
    laction_cnt.value = "0";
  }


  Future<void> getSowList() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "sow", "K", mUser.value.user_id, mUser.value.last_farm_no,null,null).then((it) async {
      await pr?.hide();
      ReturnSowMap _response = DioService.dioSowResponse(it);
      logger.i("getSowList() Response => ${_response.list_count} || ${_response.sow_list}");
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
          logger.e("getSowList() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getSowList() default Error : => ${obj}");
          break;
      }
    });
  }

  Future<void> getCode(String? code) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCode( code, "K",access_key: mUser.value.access_key, user_id: mUser.value.user_id).then((it) async {
      ReturnCodeMap _response = DioService.dioCodeResponse(it);
      logger.i("getCode() Response => ${_response.list_count} || ${_response.code_list}");
      if (_response.code_list!.length > 0) {
        if(code == "BREED_GBN_D") {
          if(dead_code.length > 0) dead_code.clear();
          List<CodeModel> list =_response.code_list as List<CodeModel>;
          dead_code.addAll(list);
          select_dead_code.value = dead_code[0];
        }else if(code == "BREED_REASON") {
          if(dead_reason_code.length > 0) dead_reason_code.clear();
          dead_reason_code.value =_response.code_list as List<CodeModel>;
          select_dead_reason_code.value = dead_reason_code[0];
        }
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getCode() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getCode() default Error : => ${obj}");
          break;
      }
    });
  }

  Future<void> saveSow() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).saveSow(mUser.value.access_key, "out_insert", "K", mUser.value.user_id, mUser.value.last_farm_no,Util.getDate(mCalendarNowDate.value), selectSowModel.value.mother_no, out_gbn: "02", out_detail_gbn: select_dead_code.value.cd_id,out_reason: select_dead_reason_code.value.cd_id ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("saveSow() Response => ${_response.error}");
      if(_response.error?["error_code"] == null || _response.error?["error_code"] == "") {
        Util.toast(context.read<MenuProvider>().translate('msg_success_save_out'));
        await getSowList();
        selectSowModel.value = SowModel();
        initEdit();
      }else{
        Util.toast("${_response.error?["error_code"]} : ${_response.error?["message"]}");
      }

    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("saveSow() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("saveSow() default Error : => ${obj}");
          break;
      }
    });
  }

  Future<void> getSearchSow() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "sow_search", "K", mUser.value.user_id, mUser.value.last_farm_no,motherNumController.text,null).then((it) async {
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
                      menuProvider.translate('out_manager'),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize16, Colors.white),
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
                workSearchWidget(),
                Container(
                    height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.47,
                    child: workList()
                ),
                workWriteWidget(),
                Container(
                        margin: EdgeInsets.only(right: CustomStyle.getWidth(15),left: CustomStyle.getWidth(15), top: CustomStyle.getHeight(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: CustomStyle.getWidth(5)),
                                child: Consumer<MenuProvider>(
                                    builder: (context, menuProvider, child) {
                                      return Obx(() => SizedBox(
                                          width: CustomStyle.getWidth(120),
                                          child: Text(
                                            menuProvider.translate('out_date'),
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(
                                                language.value == "ko" ? styleFontSize14 : styleFontSize12, Colors.black),
                                          )
                                        )
                                      );
                                    }),
                            ),
                            InkWell(
                                onTap: () {
                                  openCalendarDialog();
                                },
                                child: Container(
                                   width: CustomStyle.getWidth(150.w),
                                   height: CustomStyle.getHeight(40),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: CustomStyle.getHeight(5),
                                        horizontal: CustomStyle.getWidth(30)
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black, width: 1),
                                        borderRadius: const BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Obx(() => Text(
                                      "${mCalendarNowDate.value.year}-${mCalendarNowDate.value.month}-${mCalendarNowDate.value.day}",
                                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
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
                                        if(selectSowModel.value.mother_no != null ) {
                                          await saveSow();
                                        }else{
                                          Util.toast(context.read<MenuProvider>().translate('msg_select_save_mother'));
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
                                                    menuProvider.translate('out_save'),
                                                    style: CustomStyle.CustomFont(
                                                        language.value == "ko" ? styleFontSize18 : styleFontSize14, Colors.white),
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
                                          goToAccident();
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