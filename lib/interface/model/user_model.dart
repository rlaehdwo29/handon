
import 'package:handon_project/interface/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends ResultModel {
  bool? autoYn;
  String? user_id;
  String? password;
  String? site_gubun;
  String? login_yn;
  String? access_key;
  String? user_nm;
  int? last_farm_no;
  String? last_farm_nm;
  int? list_count;
  List<dynamic>? farm_list;

  UserModel({
    this.autoYn,
    this.user_id,
    this.password,
    this.site_gubun,
    this.login_yn,
    this.access_key,
    this.user_nm,
    this.last_farm_no,
    this.last_farm_nm,
    this.list_count,
    this.farm_list
  });

  factory UserModel.fromJSON(Map<String,dynamic> json){
      return UserModel(
        autoYn : json['autoYn'],
        user_id : json['user_id'],
        password : json['password'],
        site_gubun : json['site_gubun'],
        login_yn : json['login_yn'],
        access_key : json['access_key'],
        user_nm : json['user_nm'],
        last_farm_no : json['last_farm_no'] == null || json['last_farm_no'] == "null" ? 0 : json['last_farm_no'] ,
        last_farm_nm : json['last_farm_nm'],
        list_count : json['list_count'] == null || json['list_count'] == "null" ? 0 : json['list_count'] ,
        farm_list : json['farm_list'] as List<dynamic>? ,
      );

  }

  Map<String,dynamic> toJson() => _$UserModelToJson(this);
}