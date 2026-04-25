// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Month _$MonthFromJson(Map<String, dynamic> json) => Month(
  id: json['i'] as String,
  yearMonth: (json['ym'] as num).toInt(),
  comment: json['c'] as String? ?? "",
  updatedAt: (json['ua'] as num?)?.toInt(),
  salary: (json['sg'] as num?)?.toDouble(),
  bonus: (json['sb'] as num?)?.toDouble(),
  position: json['sp'] as String?,
  company: json['sco'] as String?,
  salaryComment: json['sc'] as String?,
);

Map<String, dynamic> _$MonthToJson(Month instance) => <String, dynamic>{
  'i': instance.id,
  'ym': instance.yearMonth,
  'c': instance.comment,
  'ua': instance.updatedAt,
  'sg': instance.salary,
  'sb': instance.bonus,
  'sp': instance.position,
  'sco': instance.company,
  'sc': instance.salaryComment,
};
