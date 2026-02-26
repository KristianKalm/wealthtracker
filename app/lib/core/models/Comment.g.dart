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
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'i': instance.id,
  'ym': instance.yearMonth,
  'c': instance.comment,
  'ua': instance.updatedAt,
};
