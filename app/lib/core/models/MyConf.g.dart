// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MyConf.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyConf _$MyConfFromJson(Map<String, dynamic> json) => MyConf(
  id: json['i'] as String,
  isDarkTheme: json['isDarkTheme'] as bool,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  assetGroups:
      (json['assetGroups'] as List<dynamic>?)
          ?.map((e) => AssetGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  customConfigs: json['customConfigs'] as Map<String, dynamic>,
  updatedAt: (json['ua'] as num?)?.toInt(),
);

Map<String, dynamic> _$MyConfToJson(MyConf instance) => <String, dynamic>{
  'i': instance.id,
  'isDarkTheme': instance.isDarkTheme,
  'tags': instance.tags.map((e) => e.toJson()).toList(),
  'assetGroups': instance.assetGroups.map((e) => e.toJson()).toList(),
  'customConfigs': instance.customConfigs,
  'ua': instance.updatedAt,
};
