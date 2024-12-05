// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sow_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SowInfoModel _$SowInfoModelFromJson(Map<String, dynamic> json) => SowInfoModel(
      mother_no: (json['mother_no'] as num?)?.toInt(),
      pig_coupon: json['pig_coupon'] as String?,
      pig_kind: json['pig_kind'] as String?,
      ear_no: json['ear_no'] as String?,
      pig_line: json['pig_line'] as String?,
      birth: json['birth'] as String?,
      day_age: (json['day_age'] as num?)?.toInt(),
      customer_nm: json['customer_nm'] as String?,
      parity: (json['parity'] as num?)?.toInt(),
      pig_status: json['pig_status'] as String?,
      pig_status_cd: json['pig_status_cd'] as String?,
      last_work_date: json['last_work_date'] as String?,
      delivery_due_date: json['delivery_due_date'] as String?,
      out_date: json['out_date'] as String?,
      out_reason: json['out_reason'] as String?,
    )
      ..error = json['error'] as Map<String, dynamic>?
      ..list_count = (json['list_count'] as num?)?.toInt()
      ..sow_info = json['sow_info'] as Map<String, dynamic>?
      ..breed_list = json['breed_list'] as List<dynamic>?;

Map<String, dynamic> _$SowInfoModelToJson(SowInfoModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'sow_info': instance.sow_info,
      'breed_list': instance.breed_list,
      'mother_no': instance.mother_no,
      'pig_coupon': instance.pig_coupon,
      'pig_kind': instance.pig_kind,
      'ear_no': instance.ear_no,
      'pig_line': instance.pig_line,
      'birth': instance.birth,
      'day_age': instance.day_age,
      'customer_nm': instance.customer_nm,
      'parity': instance.parity,
      'pig_status': instance.pig_status,
      'pig_status_cd': instance.pig_status_cd,
      'last_work_date': instance.last_work_date,
      'delivery_due_date': instance.delivery_due_date,
      'out_date': instance.out_date,
      'out_reason': instance.out_reason,
    };
