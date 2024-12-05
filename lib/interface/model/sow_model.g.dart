// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SowModel _$SowModelFromJson(Map<String, dynamic> json) => SowModel(
      mother_no: (json['mother_no'] as num?)?.toInt(),
      pig_coupon: json['pig_coupon'] as String?,
      parity: (json['parity'] as num?)?.toInt(),
      pig_status: json['pig_status'] as String?,
      pig_status_cd: json['pig_status_cd'] as String?,
      birth: json['birth'] as String?,
      last_work_date: json['last_work_date'] as String?,
      delivery_due_date: json['delivery_due_date'] as String?,
      pregnant_days: json['pregnant_days'] as String?,
      delivery_date: json['delivery_date'] as String?,
      lactation_count: json['lactation_count'] as String?,
      index: (json['index'] as num?)?.toInt(),
    )
      ..error = json['error'] as Map<String, dynamic>?
      ..list_count = (json['list_count'] as num?)?.toInt()
      ..sow_list = json['sow_list'] as List<dynamic>?;

Map<String, dynamic> _$SowModelToJson(SowModel instance) => <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'sow_list': instance.sow_list,
      'mother_no': instance.mother_no,
      'pig_coupon': instance.pig_coupon,
      'parity': instance.parity,
      'pig_status': instance.pig_status,
      'pig_status_cd': instance.pig_status_cd,
      'birth': instance.birth,
      'last_work_date': instance.last_work_date,
      'delivery_due_date': instance.delivery_due_date,
      'pregnant_days': instance.pregnant_days,
      'delivery_date': instance.delivery_date,
      'lactation_count': instance.lactation_count,
      'index': instance.index,
    };
