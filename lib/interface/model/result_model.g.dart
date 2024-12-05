// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultModel _$ResultModelFromJson(Map<String, dynamic> json) => ResultModel(
      error: json['error'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResultModelToJson(ResultModel instance) =>
    <String, dynamic>{
      'error': instance.error,
    };

ResultFarmModel _$ResultFarmModelFromJson(Map<String, dynamic> json) =>
    ResultFarmModel(
      farm_no: (json['farm_no'] as num?)?.toInt(),
      farm_nm: json['farm_nm'] as String?,
    );

Map<String, dynamic> _$ResultFarmModelToJson(ResultFarmModel instance) =>
    <String, dynamic>{
      'farm_no': instance.farm_no,
      'farm_nm': instance.farm_nm,
    };

ResultLoginModel _$ResultLoginModelFromJson(Map<String, dynamic> json) =>
    ResultLoginModel(
      site_gubun: json['site_gubun'] as String?,
      user_id: json['user_id'] as String?,
      login_yn: json['login_yn'] as String?,
      access_key: json['access_key'] as String?,
      user_nm: json['user_nm'] as String?,
      last_farm_no: (json['last_farm_no'] as num?)?.toInt(),
      last_farm_nm: json['last_farm_nm'] as String?,
      list_count: (json['list_count'] as num?)?.toInt(),
      farm_list: json['farm_list'] as List<dynamic>?,
    );

Map<String, dynamic> _$ResultLoginModelToJson(ResultLoginModel instance) =>
    <String, dynamic>{
      'site_gubun': instance.site_gubun,
      'user_id': instance.user_id,
      'login_yn': instance.login_yn,
      'access_key': instance.access_key,
      'user_nm': instance.user_nm,
      'last_farm_no': instance.last_farm_no,
      'last_farm_nm': instance.last_farm_nm,
      'list_count': instance.list_count,
      'farm_list': instance.farm_list,
    };

ResultSowModel _$ResultSowModelFromJson(Map<String, dynamic> json) =>
    ResultSowModel(
      error: json['error'] as Map<String, dynamic>?,
      list_count: (json['list_count'] as num?)?.toInt(),
      sow_list: json['sow_list'] as List<dynamic>?,
    );

Map<String, dynamic> _$ResultSowModelToJson(ResultSowModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'sow_list': instance.sow_list,
    };

ResultCodeModel _$ResultCodeModelFromJson(Map<String, dynamic> json) =>
    ResultCodeModel(
      error: json['error'] as Map<String, dynamic>?,
      list_count: (json['list_count'] as num?)?.toInt(),
      code_list: json['code_list'] as List<dynamic>?,
    );

Map<String, dynamic> _$ResultCodeModelToJson(ResultCodeModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'code_list': instance.code_list,
    };

ResultSowDetailModel _$ResultSowDetailModelFromJson(
        Map<String, dynamic> json) =>
    ResultSowDetailModel(
      error: json['error'] as Map<String, dynamic>?,
      list_count: (json['list_count'] as num?)?.toInt(),
      sow_info: json['sow_info'] as Map<String, dynamic>?,
      breed_list: json['breed_list'] as List<dynamic>?,
    );

Map<String, dynamic> _$ResultSowDetailModelToJson(
        ResultSowDetailModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'sow_info': instance.sow_info,
      'breed_list': instance.breed_list,
    };

ResultWorkModel _$ResultWorkModelFromJson(Map<String, dynamic> json) =>
    ResultWorkModel(
      error: json['error'] as Map<String, dynamic>?,
      list_count: (json['list_count'] as num?)?.toInt(),
      p_tot_count: (json['p_tot_count'] as num?)?.toInt(),
      p_real_count: (json['p_real_count'] as num?)?.toInt(),
      p_lactation_count: (json['p_lactation_count'] as num?)?.toInt(),
      p_wean_count: (json['p_wean_count'] as num?)?.toInt(),
      work_list: json['work_list'] as List<dynamic>?,
    );

Map<String, dynamic> _$ResultWorkModelToJson(ResultWorkModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'p_tot_count': instance.p_tot_count,
      'p_real_count': instance.p_real_count,
      'p_lactation_count': instance.p_lactation_count,
      'p_wean_count': instance.p_wean_count,
      'work_list': instance.work_list,
    };
