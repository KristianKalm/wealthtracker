// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  id: json['id'] as String,
  name: json['name'] as String?,
  createdAt: (json['created_at'] as num).toInt(),
  lastUsedAt: (json['last_used_at'] as num?)?.toInt(),
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
  'last_used_at': instance.lastUsedAt,
};

TokensResponse _$TokensResponseFromJson(Map<String, dynamic> json) =>
    TokensResponse(
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokensResponseToJson(TokensResponse instance) =>
    <String, dynamic>{'tokens': instance.tokens};
