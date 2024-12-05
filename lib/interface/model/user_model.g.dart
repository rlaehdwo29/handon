// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      autoYn: json['autoYn'] as bool?,
      user_id: json['user_id'] as String?,
      password: json['password'] as String?,
      site_gubun: json['site_gubun'] as String?,
      login_yn: json['login_yn'] as String?,
      access_key: json['access_key'] as String?,
      user_nm: json['user_nm'] as String?,
      last_farm_no: (json['last_farm_no'] as num?)?.toInt(),
      last_farm_nm: json['last_farm_nm'] as String?,
      list_count: (json['list_count'] as num?)?.toInt(),
      farm_list: json['farm_list'] as List<dynamic>?,
    )..error = json['error'] as Map<String, dynamic>?;

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'error': instance.error,
      'autoYn': instance.autoYn,
      'user_id': instance.user_id,
      'password': instance.password,
      'site_gubun': instance.site_gubun,
      'login_yn': instance.login_yn,
      'access_key': instance.access_key,
      'user_nm': instance.user_nm,
      'last_farm_no': instance.last_farm_no,
      'last_farm_nm': instance.last_farm_nm,
      'list_count': instance.list_count,
      'farm_list': instance.farm_list,
    };
