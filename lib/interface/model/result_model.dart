import 'package:json_annotation/json_annotation.dart';
part 'result_model.g.dart';

@JsonSerializable()
class ResultModel {

  Map<String, dynamic>? error;

  ResultModel({this.error});

  factory ResultModel.fromJSON(Map<String,dynamic> json){
    return ResultModel(
      error : json['error'] as Map<String, dynamic>?
    );
  }

  Map<String,dynamic> toJson() => _$ResultModelToJson(this);

}

@JsonSerializable()
class ResultFarmModel {
  int?        farm_no;
  String?     farm_nm;

  ResultFarmModel({
    this.farm_no,
    this.farm_nm
  });

  factory ResultFarmModel.fromJSON(Map<String,dynamic> json){
    return ResultFarmModel(
      farm_no : json['farm_no'] == null || json['farm_no'] == "null" ? 0 : json['farm_no'],
      farm_nm : json['farm_nm']??"",
    );
  }
}


@JsonSerializable()
class ResultLoginModel {

  String? site_gubun;
  String? user_id;
  String? login_yn;
  String? access_key;
  String? user_nm;
  int? last_farm_no;
  String? last_farm_nm;
  int? list_count;
  List<dynamic>? farm_list;

  ResultLoginModel({this.site_gubun,this.user_id,this.login_yn,this.access_key, this.user_nm, this.last_farm_no, this.last_farm_nm, this.list_count, this.farm_list});

  factory ResultLoginModel.fromJSON(Map<String,dynamic> json){
    return ResultLoginModel(
        site_gubun: json['site_gubun'],
        user_id: json['user_id'],
        login_yn: json['login_yn'],
        access_key: json['access_key'],
        user_nm : json['user_nm'],
        last_farm_no : json['last_farm_no'],
        last_farm_nm : json['last_farm_nm'],
        list_count : json['list_count'],
        farm_list : json['farm_list'] as List<dynamic>?
    );
  }

  Map<String,dynamic> toJson() => _$ResultLoginModelToJson(this);

}

@JsonSerializable()
class ResultSowModel {
  Map<String,dynamic>?    error;
  int?              list_count;
  List<dynamic>?    sow_list;

  ResultSowModel({
    this.error,
    this.list_count,
    this.sow_list
  });

  factory ResultSowModel.fromJSON(Map<String,dynamic> json){
    return ResultSowModel(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json ['list_count'],
        sow_list : json['sow_list']
    );
  }

  Map<String,dynamic> toJson() => _$ResultSowModelToJson(this);

}

@JsonSerializable()
class ResultCodeModel {
  Map<String,dynamic>?    error;
  int?              list_count;
  List<dynamic>?    code_list;

  ResultCodeModel({
    this.error,
    this.list_count,
    this.code_list
  });

  factory ResultCodeModel.fromJSON(Map<String,dynamic> json){
    return ResultCodeModel(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json ['list_count'],
        code_list : json['code_list']
    );
  }

  Map<String,dynamic> toJson() => _$ResultCodeModelToJson(this);

}

@JsonSerializable()
class ResultSowDetailModel {
  Map<String,dynamic>?    error;
  int?              list_count;
  Map<String,dynamic>?     sow_info;
  List<dynamic>?    breed_list;

  ResultSowDetailModel({
    this.error,
    this.list_count,
    this.sow_info,
    this.breed_list
  });

  factory ResultSowDetailModel.fromJSON(Map<String,dynamic> json){
    return ResultSowDetailModel(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json ['list_count'],
        sow_info : json['sow_info'] as Map<String, dynamic>?,
        breed_list : json['breed_list']
    );
  }

  Map<String,dynamic> toJson() => _$ResultSowDetailModelToJson(this);

}

@JsonSerializable()
class ResultWorkModel {
  Map<String,dynamic>?    error;
  int?              list_count;
  int?              p_tot_count;
  int?              p_real_count;
  int?              p_lactation_count;
  int?              p_wean_count;
  List<dynamic>?    work_list;

  ResultWorkModel({
    this.error,
    this.list_count,
    this.p_tot_count,
    this.p_real_count,
    this.p_lactation_count,
    this.p_wean_count,
    this.work_list
  });

  factory ResultWorkModel.fromJSON(Map<String,dynamic> json){
    return ResultWorkModel(
        error : json['error'] as Map<String, dynamic>?,
        list_count : json ['list_count'],
        p_tot_count : json['p_tot_count'],
        p_real_count : json['p_real_count'],
        p_lactation_count : json['p_lactation_count'],
        p_wean_count : json['p_wean_count'],
        work_list : json['work_list']
    );
  }

  Map<String,dynamic> toJson() => _$ResultWorkModelToJson(this);

}