
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/page/level_1/level_2/accident_detail_page.dart';
import 'package:handon_project/page/level_1/level_2/qr_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/util.dart';
import 'package:logger/logger.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class IndividualPage extends StatefulWidget {

  IndividualPage({Key? key}) : super(key:key);

  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();

  final mList = List.empty(growable: true).obs;
  final mUser = UserModel().obs;
  final selectSowModel = SowModel().obs;
  final mCalendarNowDate = DateTime.now().obs;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final language = "my".obs;  // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어

  late TextEditingController motherNumController;

  final total_cnt = "0".obs;
  final laction_cnt = "0".obs;

  @override
  void initState() {
    super.initState();
    motherNumController = TextEditingController();
    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
      await getSowList();   // 개체관리 List Widget
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
                              menuProvider.translate('mother_no'),    // <다국어> 모돈번호
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
                        onChanged: (value) async {

                        },
                        maxLength: 50,
                      )
                  ),
                ]),
            InkWell(
                onTap: (){
                  goToQRPage();   // Qr코드 페이지 이동 Function
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

    //  개체관리 List
  Widget indivisualList() {
    return Column(
        children: [
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
                  child:Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return Text(
                          menuProvider.translate('mother_no'),  // <다국어> 모돈번호
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
                          menuProvider.translate('parity'), // <다국어> 산차
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.white),
                        );
                      }),
                ),
                Expanded(
                  flex: 2,
                  child:Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        return Text(
                          menuProvider.translate('pig_status'), // <다국어> 현재상태
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
                          menuProvider.translate('last_work_date'), // <다국어> 최종작업일
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
                      return getListView(item,index);   // 개체관리 List Item
                    }
            ),
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
                          menuProvider.translate('no_search'),    // <다국어> 검색된 목록이 없습니다
                          style: CustomStyle.CustomFont(styleFontSize18, Colors.black),
                        ));
                  }),
            ),
          )
      ]
    );
  }

  /**
   * 개체관리 List Item
   */
  Widget getListView(SowModel item, int _index) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(PageAnimationTransition(page: AccidentDetailPage(sowModel: item), pageAnimationType: RightToLeftFadedTransition()));
      },
      child: Container(
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
            flex: 2,
            child: Text(
              "${item.pig_status}", // 현재상태
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${item.last_work_date??"-"}",    // 최종작업일
              textAlign: TextAlign.center,
            style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
            )
          ),
        ],
      )
      )
    );
  }

  /**
   * 모돈 번호로 검색한 List Dialog
   */
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
                                        menuProvider.translate('mother_no'),    // <다국어> 모돈번호
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
                                        menuProvider.translate('parity'),   //<다국어> 산차
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
                                          menuProvider.translate('pig_status'),   // <다국어> 현재상태
                                          style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize15 : styleFontSize12, Colors.black,font_weight: FontWeight.w800),
                                        ));
                                  })
                          ),
                        ],
                      )
                    ],
                  )),
                  content:  SizedBox(
                    width: double.maxFinite, // 최대 가로 크기 설정
                    height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.5,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true, // 높이를 내용물에 맞추도록 설정
                      itemCount: list?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = list?[index];
                        return InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(PageAnimationTransition(page: AccidentDetailPage(sowModel: item), pageAnimationType: RightToLeftFadedTransition()));
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
                                      "${item?.pig_coupon}",    // 모돈번호
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${item?.parity}",  // 산차
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${item?.pig_status}",    // 현재상태
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


  /**
   * Qr코드 페이지 이동 Function
   */
  Future<void> goToQRPage() async {
    Map<String,dynamic> results = await Navigator.of(context).push(PageAnimationTransition(page: QRPage(code: "individual"), pageAnimationType: RightToLeftFadedTransition()));

    // QR코드 화면에서 처리 된 값 갱신
    if(results.containsKey("code")){
      if(results["code"] == 200) {
        int _index = mList.indexWhere((element) => element.mother_no == results["selectItem"].mother_no);
        print("goToQRPage() -> ${_index} // ${results["selectItem"].mother_no} // ${results["selectItem"].pig_coupon}");
        if(_index < 0) {
          Util.toast((context.read<MenuProvider>().translate('msg_not_match_mother_no')));    // <다국어> 일치하는 모돈 번호가 없습니다.
        }else {
          selectSowModel.value = results["selectItem"];
          await Navigator.of(context).push(PageAnimationTransition(page: AccidentDetailPage(sowModel: selectSowModel.value), pageAnimationType: RightToLeftFadedTransition()));
        }
      }
    }
  }

  /**
   *  개체관리 List Widget
   */
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
    Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));  // <다국어> 서버연결에 문제가 있습니다.
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

  /**
   * 모돈번호 검색 API
   */
  Future<void> getSearchSow() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "sow_search", "K", mUser.value.user_id, mUser.value.last_farm_no,motherNumController.text,null).then((it) async {
      await pr?.hide();
      ReturnSowMap _response = DioService.dioSowResponse(it);
      logger.i("getSowList() Response => ${_response.list_count} || ${_response.sow_list}");
      List<SowModel>? sow = _response.sow_list;
        openListDialog(this.context, sow);  // 검색된 모돈번호 List Dialog
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));    // <다국어> 서버연결에 문제가 있습니다.
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
          title:  Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
                return Text(
                      menuProvider.translate('individual_manager'),   // <다국어> 개체관리
                      softWrap: true,
                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize16, Colors.white),
                    );
              }),
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
                child: Column(
              children: [
                workSearchWidget(),   // 모돈번호 검색 Widget
                Container( // 총 개체 개수 Widget
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                menuProvider.translate('total'),  //<다국어> 총
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
                                menuProvider.translate('do'),   //<다국어> 두
                                style: CustomStyle.CustomFont(
                                    language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                              ));
                        }),
                  ],
                )),
                SizedBox(
                    height: MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.8,
                    child: indivisualList()   // 개체관리 List Widget
                ),
              ],
            ));
          }),
        ),
      )
    );
  }
}