import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class Util {

  static toast(String? msg) {
    return Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: light_gray3,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static String getDate(DateTime? calendar){
    return DateFormat("yyyyMMdd").format(calendar!);
  }

  static String getAllDate(DateTime calendar) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(calendar);
  }

  static String getTextDate(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  static String mergeAllDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMddHHmmss").format(DateTime.parse(d));
  }

  static String mergeDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMdd").format(DateTime.parse(d));
  }

  static String mergeTime(String date) {
    DateFormat dateFormat = DateFormat("HH:mm",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("HHmm").format(DateTime.parse(d));
  }

  static ProgressDialog? networkProgress(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal,
        isDismissible: false,
        showLogs: false,
        customBody: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(CustomStyle.getWidth(8.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: CustomStyle.getWidth(50.0),
                  height: CustomStyle.getHeight(50.0),
                  child: const CircularProgressIndicator(
                      ),
                )
              ],
            )));
    pr.style(backgroundColor: Colors.transparent, elevation: 0.0);
    return pr;
  }

  static String? getStatusMsg(BuildContext context, String? code, SowModel? model) {
      if (model?.pig_coupon == null || model?.pig_coupon == "") {
        return context.read<MenuProvider>().translate('msg_not_search_qr');
      } else {
        if (model?.parity == null || (model?.birth == null || model?.birth == "") || (model?.pig_status_cd == null || model?.pig_status_cd == "")) {
          return context.read<MenuProvider>().translate('msg_no_mother_no');
          //return "\"등록되지 않은 모돈번호입니다.\n등록여부를 먼저 확인해 주십시오.\"";
        } else{
          if(code == "mate") {
            if (model?.pig_status_cd == "J" || model?.pig_status_cd == "M" || model?.pig_status_cd == "N") {
              return context.read<MenuProvider>().translate('msg_success_mate');
            } else if (model?.pig_status_cd == "K")  {
              return context.read<MenuProvider>().translate('msg_no_mate');
              //return "\"교배예정돈이 아닙니다.\n교배입력을 진행하시겠습니까?\"";
            } else {
              //return "\"교배입력이 불가합니다.\n모돈의 현재상태를 먼저 확인해 주십시오.\"";
              context.read<MenuProvider>().translate('msg_no_write_mate');
            }
          }else if(code == "delivery") {
            if (model?.pig_status_cd == "K") {
              //return "\"선택한 분만 대상 모돈입니다.\"";
              return context.read<MenuProvider>().translate('msg_success_delivery');
            } else {
              //return "\"분만입력이 불가합니다.\n모돈의 현재상태를 먼저 확인해 주십시오.\"";
              return context.read<MenuProvider>().translate('msg_no_write_delivery');
            }
          }else if(code == "wean") {
            if (model?.pig_status_cd == "L") {
              //return "\"선택한 이유 대상 모돈입니다.\"";
              return context.read<MenuProvider>().translate('msg_success_wean');
            } else {
              //return "\"이유입력이 불가합니다.\n모돈의 현재상태를 먼저 확인해 주십시오.\"";
              return context.read<MenuProvider>().translate('msg_no_write_wean');
            }
          }else if(code == "accident") {
            if (model?.pig_status_cd == "K") {
              //return "\"개체선택이 완료되었습니다.\"";
              return context.read<MenuProvider>().translate('msg_sucess_individual');
            } else {
              //return "\"임신사고입력이 불가합니다.\n모돈의 현재상태를 먼저 확인해 주십시오.\"";
              return context.read<MenuProvider>().translate('msg_no_write_accident');
            }
          }else if(code == "out") {
            if (model?.pig_status_cd == "O" || model?.pig_status_cd == "P" ) {
              //return "\"도폐입력이 불가합니다.\n모돈의 현재상태를 먼저 확인해 주십시오.\"";
              return context.read<MenuProvider>().translate('msg_no_write_out');
            } else {
              return context.read<MenuProvider>().translate('msg_sucess_individual');
              //return "\"개체선택이 완료되었습니다.\"";
            }
          }else {
            //return "\"개체선택이 완료되었습니다.\"";
            return context.read<MenuProvider>().translate('msg_sucess_individual');
          }
        }
      }
  }

  static String? getStatusCode(String? code, SowModel? model) {
    if(model?.pig_coupon == null || model?.pig_coupon == "") {
      return "01";
    }else {
      if(model?.parity == null || (model?.birth == null || model?.birth == "" ) || (model?.pig_status_cd == null || model?.pig_status_cd == "")) {
        return "02";
      } else{
        if(code == "mate") {
          if (model?.pig_status_cd == "J" || model?.pig_status_cd == "M" || model?.pig_status_cd == "N") {
            return "00";
          } else if (model?.pig_status_cd == "K") {
            return "04";
          } else {
            return "03";
          }
        }else if(code == "delivery") {
          if (model?.pig_status_cd == "K") {
            return "00";
          } else {
            return "03";
          }
        }else if(code == "wean") {
          if (model?.pig_status_cd == "L") {
            return "00";
          } else {
            return "03";
          }
        }else if(code == "accident") {
          if (model?.pig_status_cd == "K") {
            return "00";
          } else {
            return "03";
          }
        } else if(code == "out") {
          if (model?.pig_status_cd == "O" || model?.pig_status_cd == "P" ) {
            return "03";
          } else {
            return "00";
          }
        } else {
          return "00";
        }
      }
    }
  }

}
