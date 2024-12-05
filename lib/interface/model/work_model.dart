
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_model.g.dart';

@JsonSerializable()
class WorkModel extends ResultModel {
  int? mother_no;                  // 모돈번호
  String? pig_coupon;                 // 산차
  int? parity;
  String? pig_status;                 // 상태
  String? pig_status_cd;              // 상태Code
  String? mate_date;                  // 교배일
  String? repeat_yn;                  // 재교배여부
  String? delivery_due_date;          // 분만예정일
  String? delivery_date;              // 분만일
  String? tot_count;                // 총산
  String? real_count;               // 실산
  String? lactation_count;                 // 포유개시두수
  String? wean_date;                  // 이유일
  String? wean_count;                    // 이유두수
  String? out_date;                   // 도폐사일
  String? out_gubun;                  // 도폐사구분
  String? out_reason;                 // 도폐사 사유
  String? accident_date;              // 임신사고일
  String? accident_kind;              // 사고구분
  String? prg_acc;                    // 사고원인


  WorkModel({
    this.mother_no,                  // 모돈번호
    this.pig_coupon,                 // 산차
    this.parity,
    this.pig_status,                 // 상태
    this.pig_status_cd,              // 상태Code
    this.mate_date,                  // 교배일
    this.repeat_yn,                  // 재교배여부
    this.delivery_due_date,          // 분만예정일
    this.delivery_date,              // 분만일
    this.tot_count,             // 총산
    this.real_count,             // 실산
    this.lactation_count,              // 포유개시두수
    this.wean_date,                  // 이유일
    this.wean_count,             // 이유두수
    this.out_date,                   // 도폐사일
    this.out_gubun,                  // 도폐사구분
    this.out_reason,                 // 도폐사 사유
    this.accident_date,              // 임신사고일
    this.accident_kind,              // 사고구분
    this.prg_acc                    // 사고원인
  });

  factory WorkModel.fromJSON(Map<String,dynamic> json){
    return WorkModel(
      mother_no : json['mother_no'] == null || json['mother_no'] == "null" ? 0 : json['mother_no'],
      pig_coupon : json['pig_coupon'] == null || json['pig_coupon'] == "null" ? "0" : json['pig_coupon'],
      parity : json['parity'] == null || json['parity'] == "null" ? 0 : json['parity'],
      pig_status : json['pig_status'],
      pig_status_cd : json['pig_status_cd'],
      mate_date : json['mate_date'],
      repeat_yn : json['repeat_yn'],
      delivery_due_date : json['delivery_due_date'],
      delivery_date : json['delivery_date'],
      tot_count : json['tot_count'] == null || json['tot_count'] == "null" ? "0" : json['tot_count'].toString(),
        real_count : json['real_count'] == null || json['real_count'] == "null" ? "0" : json['real_count'].toString(),
        lactation_count : json['lactation_count'] == null || json['lactation_count'] == "null" ? "0" : json['lactation_count'].toString(),
      wean_date : json['wean_date'],
      wean_count : json['wean_count'] == null || json['wean_count'] == "null" ? "0" : json['wean_count'].toString(),
      out_date : json['out_date'],
      out_gubun : json['out_gubun'],
      out_reason : json['out_reason'],
      accident_date : json['accident_date'],
      accident_kind : json['accident_kind'],
      prg_acc : json['prg_acc']
    );
  }

  Map<String,dynamic> toJson() => _$WorkModelToJson(this);
}