
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sow_model.g.dart';

@JsonSerializable()
class SowModel extends ResultSowModel {
  int? mother_no;
  String?    pig_coupon;              // 모돈번호
  int? parity;                        // 산차
  String? pig_status;                 // 상태
  String? pig_status_cd;              // 상태Code
  String? birth;                      // 생년월일
  String? last_work_date;             // 최종작업일
  String? delivery_due_date;          // 분만예정일
  String? pregnant_days;              // 임신일령
  String? delivery_date;              // 분만일
  String? lactation_count;              // 포유개시두수
  int? index;

  SowModel({
    this.mother_no,
    this.pig_coupon,
    this.parity,
    this.pig_status,
    this.pig_status_cd,
    this.birth,
    this.last_work_date,
    this.delivery_due_date,
    this.pregnant_days,
    this.delivery_date,
    this.lactation_count,
    this.index,
  });

  factory SowModel.fromJSON(Map<String,dynamic> json){
    return SowModel(
      mother_no : json['mother_no'] == null || json['mother_no'] == "null" ? 0 : json['mother_no'],
      pig_coupon : json['pig_coupon'] == null || json['pig_coupon'] == "null" ? "0" : json['pig_coupon'],
      parity : json['parity'] == null || json['parity'] == "null" ? 0 : json['parity'],
      pig_status : json['pig_status'],
      pig_status_cd : json['pig_status_cd'],
      birth : json['birth'],
      last_work_date : json['last_work_date'],
      delivery_due_date : json['delivery_due_date'],
      pregnant_days : json['pregnant_days'] == null || json['pregnant_days'] == "null" ? "0" : json['pregnant_days'].toString(),
      delivery_date : json['delivery_date'],
      lactation_count : json['lactation_count'] == null || json['lactation_count'] == "null" ? "0" : json['lactation_count'].toString(),
    );
  }

  Map<String,dynamic> toJson() => _$SowModelToJson(this);
}