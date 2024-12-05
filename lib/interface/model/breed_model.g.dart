// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedModel _$BreedModelFromJson(Map<String, dynamic> json) => BreedModel(
      parity: (json['parity'] as num?)?.toInt(),
      mate_date: json['mate_date'] as String?,
      delivery_date: json['delivery_date'] as String?,
      pregnant_days: (json['pregnant_days'] as num?)?.toInt(),
      tot_count: (json['tot_count'] as num?)?.toInt(),
      dead_count: (json['dead_count'] as num?)?.toInt(),
      mummy_count: (json['mummy_count'] as num?)?.toInt(),
      selection_count: (json['selection_count'] as num?)?.toInt(),
      lactation_count: (json['lactation_count'] as num?)?.toInt(),
      lactation_days: (json['lactation_days'] as num?)?.toInt(),
      wean_date: json['wean_date'] as String?,
      wean_count: (json['wean_count'] as num?)?.toInt(),
    )
      ..error = json['error'] as Map<String, dynamic>?
      ..list_count = (json['list_count'] as num?)?.toInt()
      ..sow_list = json['sow_list'] as List<dynamic>?;

Map<String, dynamic> _$BreedModelToJson(BreedModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'list_count': instance.list_count,
      'sow_list': instance.sow_list,
      'parity': instance.parity,
      'mate_date': instance.mate_date,
      'delivery_date': instance.delivery_date,
      'pregnant_days': instance.pregnant_days,
      'tot_count': instance.tot_count,
      'dead_count': instance.dead_count,
      'mummy_count': instance.mummy_count,
      'selection_count': instance.selection_count,
      'lactation_count': instance.lactation_count,
      'lactation_days': instance.lactation_days,
      'wean_date': instance.wean_date,
      'wean_count': instance.wean_count,
    };
