// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkModel _$WorkModelFromJson(Map<String, dynamic> json) => WorkModel(
      mother_no: (json['mother_no'] as num?)?.toInt(),
      pig_coupon: json['pig_coupon'] as String?,
      parity: (json['parity'] as num?)?.toInt(),
      pig_status: json['pig_status'] as String?,
      pig_status_cd: json['pig_status_cd'] as String?,
      mate_date: json['mate_date'] as String?,
      repeat_yn: json['repeat_yn'] as String?,
      delivery_due_date: json['delivery_due_date'] as String?,
      delivery_date: json['delivery_date'] as String?,
      tot_count: json['tot_count'] as String?,
      real_count: json['real_count'] as String?,
      lactation_count: json['lactation_count'] as String?,
      wean_date: json['wean_date'] as String?,
      wean_count: json['wean_count'] as String?,
      out_date: json['out_date'] as String?,
      out_gubun: json['out_gubun'] as String?,
      out_reason: json['out_reason'] as String?,
      accident_date: json['accident_date'] as String?,
      accident_kind: json['accident_kind'] as String?,
      prg_acc: json['prg_acc'] as String?,
    )..error = json['error'] as Map<String, dynamic>?;

Map<String, dynamic> _$WorkModelToJson(WorkModel instance) => <String, dynamic>{
      'error': instance.error,
      'mother_no': instance.mother_no,
      'pig_coupon': instance.pig_coupon,
      'parity': instance.parity,
      'pig_status': instance.pig_status,
      'pig_status_cd': instance.pig_status_cd,
      'mate_date': instance.mate_date,
      'repeat_yn': instance.repeat_yn,
      'delivery_due_date': instance.delivery_due_date,
      'delivery_date': instance.delivery_date,
      'tot_count': instance.tot_count,
      'real_count': instance.real_count,
      'lactation_count': instance.lactation_count,
      'wean_date': instance.wean_date,
      'wean_count': instance.wean_count,
      'out_date': instance.out_date,
      'out_gubun': instance.out_gubun,
      'out_reason': instance.out_reason,
      'accident_date': instance.accident_date,
      'accident_kind': instance.accident_kind,
      'prg_acc': instance.prg_acc,
    };
