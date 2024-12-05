
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_model.g.dart';

@JsonSerializable()
class CodeModel extends ResultCodeModel {
  String?     cd_id;
  String?     cd_nm;

  CodeModel({
    this.cd_id,
    this.cd_nm,
  });

  factory CodeModel.fromJSON(Map<String,dynamic> json){
    return CodeModel(
      cd_id : json['cd_id']??"",
      cd_nm : json['cd_nm']??"",
    );
  }

  Map<String,dynamic> toJson() => _$CodeModelToJson(this);
}