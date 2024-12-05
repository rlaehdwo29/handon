
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sow_info_model.g.dart';

@JsonSerializable()
class SowInfoModel extends ResultSowDetailModel {
  int? mother_no;
  String? pig_coupon;                 // 모돈번호
  String? pig_kind;                   // 품종
  String? ear_no;                     //이각번호
  String? pig_line;                   //계통
  String? birth;                      // 생년월일
  int? day_age;                       // 생후일령
  String? customer_nm;                //구입처
  int? parity;                      // 산차
  String? pig_status;               // 상태
  String? pig_status_cd;            // 상태Code
  String? last_work_date;           // 최종작업일
  String? delivery_due_date;         // 분만예정일
  String? out_date;                 // 도태일자
  String? out_reason;               //도태원인

  SowInfoModel({
    this.mother_no,
    this.pig_coupon,
    this.pig_kind,
    this.ear_no,
    this.pig_line,
    this.birth,
    this.day_age,
    this.customer_nm,
    this.parity,
    this.pig_status,
    this.pig_status_cd,
    this.last_work_date,
    this.delivery_due_date,
    this.out_date,
    this.out_reason
  });

  factory SowInfoModel.fromJSON(Map<String,dynamic>? json){
    return SowInfoModel(
        mother_no : json?['mother_no'] == null || json?['mother_no'] == "null" ? 0 : json?['mother_no'],
        pig_coupon : json?['pig_coupon'],
        pig_kind : json?['pig_kind'],
        ear_no : json?['ear_no'],
        pig_line : json?['pig_line'],
        birth : json?['birth'],
        day_age : json?['day_age'] == null || json?['day_age'] == "null" ? 0 : json?['day_age'],
        customer_nm : json?['customer_nm'],
        parity : json?['parity'] == null || json?['parity'] == "null" ? 0 : json?['parity'],
        pig_status : json?['pig_status'],
        pig_status_cd : json?['pig_status_cd'],
        last_work_date : json?['last_work_date'],
        delivery_due_date : json?['delivery_due_date'],
        out_date : json?['out_date'],
        out_reason : json?['out_reason']
    );
  }

  Map<String,dynamic> toJson() => _$SowInfoModelToJson(this);
}