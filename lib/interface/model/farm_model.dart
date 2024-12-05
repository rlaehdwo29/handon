
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'farm_model.g.dart';

@JsonSerializable()
class FarmModel extends ResultFarmModel {
  int?        farm_no;
  String?     farm_nm;

  FarmModel({
    this.farm_no,
    this.farm_nm
  });


  factory FarmModel.fromJson(Map<String, dynamic> json) => _$FarmModelFromJson(json);

  Map<String,dynamic> toJson() => _$FarmModelToJson(this);
}