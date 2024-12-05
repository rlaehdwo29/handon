// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeModel _$CodeModelFromJson(Map<String, dynamic> json) => CodeModel(
      cd_id: json['cd_id'] as String?,
      cd_nm: json['cd_nm'] as String?,
    )
      ..error = json['error'] as Map<String, dynamic>?
      ..list_count = (json['list_count'] as num?)?.toInt()
      ..code_list = json['code_list'] as List<dynamic>?;

Map<String, dynamic> _$CodeModelToJson(CodeModel instance) => <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'code_list': instance.code_list,
      'cd_id': instance.cd_id,
      'cd_nm': instance.cd_nm,
    };
