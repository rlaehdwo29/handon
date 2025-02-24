import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class Util {


  /**
   *  Toast 메시지 노출
   */
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

  /**
   * DateTime String으로 변환하여 가져오기 EX)19990101
   */
  static String getDate(DateTime? calendar){
    return DateFormat("yyyyMMdd").format(calendar!);
  }

  /**
   * DateTime String으로 변환하여 가져오기 EX) 1999-01-01 13:00:00
   */
  static String getAllDate(DateTime calendar) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return dateFormat.format(calendar);
  }

  /**
   * DateTime String으로 변환하여 가져오기 EX) 1999-01-01
   */
  static String getTextDate(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  /**
   * String Date값을 변환하여 가져오기 EX) 19990101130000
   */
  static String mergeAllDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMddHHmmss").format(DateTime.parse(d));
  }

  /**
   * String Date값을 변환하여 년월일 가져오기 EX) 19990101
   */
  static String mergeDate(String date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("yyyyMMdd").format(DateTime.parse(d));
  }

  /**
   * String Date값을 변환하여 시간/분 가져오기 EX) 1300
   */
  static String mergeTime(String date) {
    DateFormat dateFormat = DateFormat("HH:mm",'ko');
    DateTime dateTime = DateTime.parse(date);
    String d = dateFormat.format(dateTime);
    return DateFormat("HHmm").format(DateTime.parse(d));
  }

  /**
   * 네트워크 통신 시 Waiting Dialog Widget
   */
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

  /**
   * QR 코드 결과 Return 시 문구 세팅
   */
  static String? getStatusMsg(BuildContext context, String? code, SowModel? model) {
      if (model?.pig_coupon == null || model?.pig_coupon == "") {
        return context.read<MenuProvider>().translate('msg_not_search_qr');   // <다국어> QR코드 인식에 실패했습니다.
      } else {
        if (model?.parity == null || (model?.birth == null || model?.birth == "") || (model?.pig_status_cd == null || model?.pig_status_cd == "")) {
          return context.read<MenuProvider>().translate('msg_no_mother_no');    // <다국어> 등록되지 않은 모돈번호입니다.
        } else{
          if(code == "mate") {
            if (model?.pig_status_cd == "J" || model?.pig_status_cd == "M" || model?.pig_status_cd == "N") {
              return context.read<MenuProvider>().translate('msg_success_mate');    // <다국어> 선택한 교배 대상 모돈입니다.
            } else if (model?.pig_status_cd == "K")  {
              return context.read<MenuProvider>().translate('msg_no_mate');   // <다국어> 교배예정돈이 아니지만 교배입력을 진행하시겠습니까?
            } else {
              return context.read<MenuProvider>().translate('msg_no_write_mate');   // <다국어> 교배입력이 불가합니다.
            }
          }else if(code == "delivery") {
            if (model?.pig_status_cd == "K") {
              return context.read<MenuProvider>().translate('msg_success_delivery');    // <다국어> 선택한 분만 대상 모돈입니다.
            } else {
              return context.read<MenuProvider>().translate('msg_no_write_delivery');   // <다국어> 분만입력이 불가합니다.
            }
          }else if(code == "wean") {
            if (model?.pig_status_cd == "L") {
              return context.read<MenuProvider>().translate('msg_success_wean');    // <다국어> 선택한 이유 대상 모돈입니다.
            } else {
              return context.read<MenuProvider>().translate('msg_no_write_wean');   // <다국어> 이유입력이 불가합니다.
            }
          }else if(code == "accident") {
            if (model?.pig_status_cd == "K") {
              return context.read<MenuProvider>().translate('msg_sucess_individual');   //< 다국어> 개체선택이 완료되었습니다.
            } else {
              return context.read<MenuProvider>().translate('msg_no_write_accident');   // <다국어> 임신사고입력이 불가합니다.
            }
          }else if(code == "out") {
            if (model?.pig_status_cd == "O" || model?.pig_status_cd == "P" ) {
              return context.read<MenuProvider>().translate('msg_selected_culled_sow');   // <다국어> 도태처리된 모돈을 선택하셨습니다.
            } else {
              return context.read<MenuProvider>().translate('msg_sucess_individual');   // <다국어> 개체선택이 완료되었습니다.
            }
          }else {
            return context.read<MenuProvider>().translate('msg_sucess_individual'); // <다국어> 개체선택이 완료되었습니다.
          }
        }
      }
  }

  /**
   * QR 코드 결과 Return 시 코드 세팅
   */
  static String? getStatusCode(String? code, SowModel? model) {
    // page_status_cd: J = 후보돈, K = 임신돈, L = 포유모돈, M = 이유모돈, N = 사고후대기돈, O = 도태, P = 폐사
    // code: 01 = 재발교배, 02 = 재발정, 03 = 미임(임신진단), 04 = 유산, 05 = 도폐사/출하(판매), 06 = 불임
    if(model?.pig_coupon == null || model?.pig_coupon == "") {
      return "01";
    }else {
      if(model?.parity == null || (model?.birth == null || model?.birth == "" ) || (model?.pig_status_cd == null || model?.pig_status_cd == "")) {
        return "02";
      } else{
        if(code == "mate") {    // 교배 화면
          if (model?.pig_status_cd == "J" || model?.pig_status_cd == "M" || model?.pig_status_cd == "N") {
            return "00";
          } else if (model?.pig_status_cd == "K") {
            return "04";
          } else {
            return "03";
          }
        }else if(code == "delivery") {    // 분만 화면
          if (model?.pig_status_cd == "K") {
            return "00";
          } else {
            return "03";
          }
        }else if(code == "wean") {      // 이유화면
          if (model?.pig_status_cd == "L") {
            return "00";
          } else {
            return "03";
          }
        }else if(code == "accident") {    // 임신사고화면
          if (model?.pig_status_cd == "K") {
            return "00";
          } else {
            return "03";
          }
        } else if(code == "out") {    // 도폐사 화면
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
