// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FarmModel _$FarmModelFromJson(Map<String, dynamic> json) => FarmModel(
      farm_no: (json['farm_no'] as num?)?.toInt(),
      farm_nm: json['farm_nm'] as String?,
    );

Map<String, dynamic> _$FarmModelToJson(FarmModel instance) => <String, dynamic>{
      'farm_no': instance.farm_no,
      'farm_nm': instance.farm_nm,
    };
