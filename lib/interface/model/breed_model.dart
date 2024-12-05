
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breed_model.g.dart';

@JsonSerializable()
class BreedModel extends ResultSowModel {
  int? parity;                        // 산차
  String? mate_date;                  // 교배일
  String? delivery_date;              // 분만일
  int? pregnant_days;                 // 임신일수
  int? tot_count;                     // 총산
  int? dead_count;                    // 사산
  int? mummy_count;                   // 미라
  int? selection_count;               // 기타
  int? lactation_count;               // 포유개시두수
  int? lactation_days;                // 포유기간
  String? wean_date;                  // 이유일
  int? wean_count;                    // 이유두수

  BreedModel({
    this.parity,
    this.mate_date,
    this.delivery_date,
    this.pregnant_days,
    this.tot_count,
    this.dead_count,
    this.mummy_count,
    this.selection_count,
    this.lactation_count,
    this.lactation_days,
    this.wean_date,
    this.wean_count
  });

  factory BreedModel.fromJSON(Map<String,dynamic> json){
    return BreedModel(
      parity : json['parity'] == null || json['parity'] == "null" ? 0 : json['parity'],
      mate_date : json['mate_date'],
      delivery_date : json['delivery_date'],
      pregnant_days : json['pregnant_days'] == null || json['pregnant_days'] == "null" ? 0 : json['pregnant_days'],
      tot_count : json['tot_count'] == null || json['tot_count'] == "null" ? 0 : json['tot_count'],
      dead_count : json['dead_count'] == null || json['dead_count'] == "null" ? 0 : json['dead_count'],
      mummy_count : json['mummy_count'] == null || json['mummy_count'] == "null" ? 0 : json['mummy_count'],
      selection_count : json['selection_count'] == null || json['selection_count'] == "null" ? 0 : json['selection_count'],
      lactation_count : json['lactation_count'] == null || json['lactation_count'] == "null" ? 0 : json['lactation_count'],
      lactation_days : json['lactation_days'] == null || json['lactation_days'] == "null" ? 0 : json['lactation_days'],
      wean_date : json['wean_date'],
      wean_count : json['wean_count'] == null || json['wean_count'] == "null" ? 0 : json['wean_count']
    );
  }

  Map<String,dynamic> toJson() => _$BreedModelToJson(this);
}