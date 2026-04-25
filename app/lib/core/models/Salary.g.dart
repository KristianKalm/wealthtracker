// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Salary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Salary _$SalaryFromJson(Map<String, dynamic> json) => Salary(
  id: json['i'] as String,
  yearMonth: (json['ym'] as num).toInt(),
  netSalary: (json['n'] as num?)?.toDouble(),
  grossSalary: (json['g'] as num?)?.toDouble(),
  bonusNet: (json['b'] as num?)?.toDouble(),
  position: json['p'] as String?,
  comment: json['c'] as String?,
  updatedAt: (json['ua'] as num?)?.toInt(),
);

Map<String, dynamic> _$SalaryToJson(Salary instance) => <String, dynamic>{
  'i': instance.id,
  'ym': instance.yearMonth,
  'n': instance.netSalary,
  'g': instance.grossSalary,
  'b': instance.bonusNet,
  'p': instance.position,
  'c': instance.comment,
  'ua': instance.updatedAt,
};
