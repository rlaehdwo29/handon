
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

  String? code;

  ManagePage({Key? key,required this.code}) : super(key:key);

  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final mList = List.empty(growable: true).obs;
  final mUser = UserModel().obs;
  final language = "my".obs;

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
      await getWorkList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /**
   * Start Widget
   */

  //  날짜 Widget
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
                   widget.code == "mate" ? "assets/image/mating.png" : widget.code == "delivery" ? "assets/image/farrowing.png" : widget.code == "wean"? "assets/image/weaning.png" : widget.code == "accident" ? "assets/image/prcheck.png" : widget.code == "out" ? "assets/image/culling.png" : "assets/image/sowcard.png",
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
                          openCalendarDialog();
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
                              // ignore: unnecessary_null_comparison
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
                              // ignore: unnecessary_null_comparison
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
                          await getWorkList();
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
                                        menuProvider.translate('search'),
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

    // mate List
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
                                menuProvider.translate('total'),
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
                                menuProvider.translate('do'),
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
                              menuProvider.translate('mother_no'),
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
                              menuProvider.translate('parity'),
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
                              menuProvider.translate('mate_date'),
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
                              menuProvider.translate('mate_state'),
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
                  return getMateListView(item);
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
                  menuProvider.translate('no_search'),
                  style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                  ));
                }),
            ),
          )
      ]
    );
  }

  // work List
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
                                menuProvider.translate('total'),
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('total'),
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
                                "${menuProvider.translate('bok')}",
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
                                menuProvider.translate('tot_count'),
                                softWrap: true,
                                maxLines: 1,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ):
                          Text(
                            menuProvider.translate('tot_count'),
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
                                menuProvider.translate('real_count'),
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('real_count'),
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
                                menuProvider.translate('lactation'),
                                softWrap: true,
                                style: CustomStyle.CustomFont(styleFontSize9, Colors.black),
                              )
                          ) :
                          Text(
                            menuProvider.translate('lactation'),
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
                                  menuProvider.translate('mother_no'),
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
                                  menuProvider.translate('parity'),
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
                            menuProvider.translate('tot_count'),
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
                                  menuProvider.translate('delivery_day'),
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
                                  menuProvider.translate('real_count'),
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
                                  menuProvider.translate('lactation'),
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
                      return getDeliveryListView(item);
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
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

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
                                menuProvider.translate('total'),
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
                                menuProvider.translate('bok'),
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
                                menuProvider.translate('lactation'),
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${p_lactation_count.value} / ",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, main_color,font_weight: FontWeight.w700),
                    ),
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('wean_child'),
                                style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                    Text(
                      " ${p_wean_count.value}",
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
                                  menuProvider.translate('mother_no'),
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
                                  menuProvider.translate('parity'),
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
                                  menuProvider.translate('wean_day'),
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
                              menuProvider.translate('lactation_count'),
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
                      return getWeanListView(item);
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
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

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
                                menuProvider.translate('total'),
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
                                menuProvider.translate('do'),
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
                                  menuProvider.translate('out_day'),
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
                                  menuProvider.translate('finish_parity'),
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
                                  menuProvider.translate('out_state'),
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
                                  menuProvider.translate('out_reason'),
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
                      return getOutListView(item);
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
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

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
                                menuProvider.translate('total'),
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
                                menuProvider.translate('do'),
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
                                  menuProvider.translate('mother_no'),
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
                                  menuProvider.translate('parity'),
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
                                  menuProvider.translate('accident_date'),
                                  style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                                ));
                          }),
                  ),
                  Expanded(
                      flex: 2,
                      child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            return Text(
                                  menuProvider.translate('accident_reason'),
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
                      return getAccidentListView(item);
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
                          menuProvider.translate('no_search'),
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
        ]
    );
  }

  Widget getMateListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
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
                  "${item.mate_date}",
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

  Widget getDeliveryListView(WorkModel item) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
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

  Widget getWeanListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
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
                flex: 3,
                child: Text(
                  "${item.wean_date??"-"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.lactation_count??0}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.wean_count??0}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
          ],
        )
    );
  }

  Widget getOutListView(WorkModel item) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
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
                  "${item.pig_coupon}",
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
                  "${item.out_date}",
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
                  "${item.parity}",
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
                  "${item.out_gubun}",
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
                  "${item.out_reason}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize11, Colors.black),
                ))
            ),
          ],
        )
    );
  }

  Widget getAccidentListView(WorkModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
        decoration: const BoxDecoration(
            color: Colors.white,
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
                  "${item.parity??"-"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.accident_date??"-"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${item.prg_acc??"-"}",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                )
            ),
          ],
        )
    );
  }

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

  /**
   * End Widget
   */

  /**
   * Start Function
   */

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
                    child: accidentSearchWidget()
                ),
                Expanded(
                    flex: 8,
                    child: widget.code == "mate" ? mateList() : widget.code == "delivery" ? deliveryList() : widget.code == "wean" ? weanList() : widget.code == "accident" ? accidentList() : widget.code == "out" ? outList() : outList()
                ),
              ],
            );
          }),
        ),
      )
    );
  }
}