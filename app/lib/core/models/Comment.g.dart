// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['i'] as String,
  yearMonth: (json['ym'] as num).toInt(),
  comment: json['c'] as String? ?? "",
  updatedAt: (json['ua'] as num?)?.toInt(),
  netSalary: (json['sn'] as num?)?.toDouble(),
  grossSalary: (json['sg'] as num?)?.toDouble(),
  bonusNet: (json['sb'] as num?)?.toDouble(),
  position: json['sp'] as String?,
  company: json['sco'] as String?,
  salaryComment: json['sc'] as String?,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'i': instance.id,
  'ym': instance.yearMonth,
  'c': instance.comment,
  'ua': instance.updatedAt,
  'sn': instance.netSalary,
  'sg': instance.grossSalary,
  'sb': instance.bonusNet,
  'sp': instance.position,
  'sco': instance.company,
  'sc': instance.salaryComment,
};
