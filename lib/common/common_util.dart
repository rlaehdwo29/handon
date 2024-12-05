import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/breed_model.dart';
import 'package:handon_project/interface/model/code_model.dart';
import 'package:handon_project/interface/model/sow_info_model.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/work_model.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:provider/provider.dart';

class ReturnMap {
  Map<String,dynamic>?    error;
  String?                 success_yn;

  ReturnMap({
    this.error,
    this.success_yn
  });

  factory ReturnMap.fromJSON(Map<String,dynamic> json){
    return ReturnMap(
        error : json['error'] as Map<String, dynamic>?,
        success_yn : json['success_yn']
    );
  }
}

class ReturnLoginMap {
  String? site_gubun;
  String? user_id;
  String? login_yn;
  String? access_key;
  String? user_nm;
  int? last_farm_no;
  String? last_farm_nm;
  int? list_count;
  List<dynamic>? farm_list;

  ReturnLoginMap({this.site_gubun,this.user_id,this.login_yn,this.access_key, this.user_nm, this.last_farm_no, this.last_farm_nm, this.list_count, this.farm_list});

  factory ReturnLoginMap.fromJSON(Map<String,dynamic> json){
    return ReturnLoginMap(
      site_gubun: json['site_gubun'],
      user_id: json['user_id'],
      login_yn: json['login_yn'],
      access_key: json['access_key'],
      user_nm : json['user_nm'],
      last_farm_no : int.parse(json['last_farm_no']),
      last_farm_nm : json['last_farm_nm'],
      list_count : int.parse(json['list_count']),
      farm_list : json['farm_list'] as List<dynamic>?
    );
  }
}

class ReturnSowMap {
  Map<String,dynamic>?    error;
  int?                list_count;
  List<SowModel>?    sow_list;

  ReturnSowMap({
    this.error,
    this.list_count,
    this.sow_list
  });

  factory ReturnSowMap.fromJSON(Map<String,dynamic> json){
    return ReturnSowMap(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json['list_count'],
        sow_list : json['sow_list'] as List<SowModel>?
    );
  }
}

class ReturnCodeMap {
  Map<String,dynamic>?    error;
  int?                list_count;
  List<CodeModel>?    code_list;

  ReturnCodeMap({
    this.error,
    this.list_count,
    this.code_list
  });

  factory ReturnCodeMap.fromJSON(Map<String,dynamic> json){
    return ReturnCodeMap(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json['list_count'],
        code_list : json['code_list'] as List<CodeModel>?
    );
  }
}

class ReturnSowDetailMap {
  Map<String,dynamic>?            error;
  int?                            list_count;
  SowInfoModel?                       sow_info;
  List<BreedModel>?               breed_list;

  ReturnSowDetailMap({
    this.error,
    this.list_count,
    this.sow_info,
    this.breed_list
  });

  factory ReturnSowDetailMap.fromJSON(Map<String,dynamic> json){
    return ReturnSowDetailMap(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json['list_count'],
        sow_info : json['sow_info'] as SowInfoModel?,
        breed_list : json['breed_list'] as List<BreedModel>?
    );
  }
}

class ReturnWorkMap {
  Map<String,dynamic>?    error;
  int?                list_count;
  int?              p_tot_count;
  int?              p_real_count;
  int?              p_lactation_count;
  int?              p_wean_count;
  List<WorkModel>?    work_list;

  ReturnWorkMap({
    this.error,
    this.list_count,
    this.p_tot_count,
    this.p_real_count,
    this.p_lactation_count,
    this.p_wean_count,
    this.work_list
  });

  factory ReturnWorkMap.fromJSON(Map<String,dynamic> json){
    return ReturnWorkMap(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json['list_count'],
        p_tot_count : json['p_tot_count'],
        p_real_count : json['p_real_count'],
        p_lactation_count : json['p_lactation_count'],
        p_wean_count : json['p_wean_count'],
        work_list : json['work_list'] as List<WorkModel>?
    );
  }
}


openOkBox(BuildContext context, String msg,String okTxt, Function() okEvent) {
  return openDialogBox(context,
      msg,
      InkWell(
          onTap: okEvent,
          child: Container(
            width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(14.0)),
            decoration: BoxDecoration(
              color: main_color,
              border: CustomStyle.borderAllBase(),
            ),
            child: Text(
              okTxt,
              style: CustomStyle.whiteFont15B(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
  );
}

openCommonConfirmBox(BuildContext context, String msg, String cancelTxt,
    String okTxt, Function() cancelEvent, Function() okEvent) {
  return openDialogBox(
    context,
    msg,
    Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: cancelEvent,
              child: Container(
                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.3,
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8.0)),
                decoration: const BoxDecoration(
                  color: light_gray1,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      return Text(
                            menuProvider.translate(cancelTxt),
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: CustomStyle.blackFont()
                          );
                    }),
              ),
            ),
            Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.05,
            ),
            InkWell(
              onTap: okEvent,
              child: Container(
                width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 0.3,
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(8.0)),
                decoration: const BoxDecoration(
                  color: main_color,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Consumer<MenuProvider>(
                    builder: (context, menuProvider, child) {
                      return Text(
                          menuProvider.translate(okTxt),
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: CustomStyle.whiteFont()
                      );
                    })
              ),
            ),
        ],
    ),
  );
}

openDialogBox(BuildContext context, String msg, Widget button) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
            contentPadding: EdgeInsets.all(CustomStyle.getWidth(15.0)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                      Icons.info,
                      size: 48,
                      color: Color(0xffC7CBDE)
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5),horizontal: CustomStyle.getWidth(10)),
                    margin: EdgeInsets.only(bottom: CustomStyle.getHeight(15)),
                    child:   Consumer<MenuProvider>(
                        builder: (context, menuProvider, child) {
                          return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: menuProvider.translate(msg),
                                  style: CustomStyle.alertMsgFont(),
                                ),
                              );
                        }),

                  ),
                  button,
                ],
              ),
            )
          ),
        );
      });
}

openSnakBar(
    {required BuildContext context,
      required ScaffoldMessengerState state,
      required String msg,
      bool closeBtn = false,
      required Function() currTapEvent,
      required Function() callback}) {
  final _snackBar = SnackBar(
    duration: Duration(milliseconds: 1500),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
      left: CustomStyle.getWidth(20.0),
      right: CustomStyle.getWidth(20.0),
      bottom: CustomStyle.getHeight(20.0),
    ),
    padding: EdgeInsets.only(
      left: CustomStyle.getWidth(10.0),
      right: CustomStyle.getWidth(10.0),
      top: CustomStyle.getHeight(14.0),
      bottom: CustomStyle.getHeight(14.0),
    ),
    backgroundColor: sub_color,
    content: InkWell(
      onTap: currTapEvent,
      child: Container(
        child: Row(
          children: <Widget>[
            closeBtn
                ? Image.asset(
              "assets/image/circle_check_false.png",
              width: CustomStyle.getWidth(17.0),
              height: CustomStyle.getHeight(17.0),
              color: styleBaseCol1,
            )
                : Container(width: 0, height: 0),
            closeBtn
                ? CustomStyle.sizedBoxWidth(5.0)
                : Container(width: 0, height: 0),
            Expanded(
              child: Text(
                msg,
                style: CustomStyle.baseFont(),
              ),
            ),
            closeBtn
                ? InkWell(
              onTap: callback,
              child: Image.asset(
                "assets/image/cancle.png",
                width: CustomStyle.getWidth(13.0),
                height: CustomStyle.getHeight(13.0),
                color: styleBaseCol1,
              ),
            )
                : Container(width: 0, height: 0),
          ],
        ),
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(_snackBar);
}