import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'created_at')
  int createdAt;
  @JsonKey(name: 'last_used_at')
  int lastUsedAt;

  Token({
    required this.id,
    this.name,
    required this.createdAt,
    required this.lastUsedAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class TokensResponse {
  @JsonKey(name: 'tokens')
  List<Token> tokens;

  TokensResponse({required this.tokens});

  factory TokensResponse.fromJson(Map<String, dynamic> json) =>
      _$TokensResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokensResponseToJson(this);
}
