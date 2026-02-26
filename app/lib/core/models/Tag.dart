import 'package:json_annotation/json_annotation.dart';

part 'Tag.g.dart';

@JsonSerializable()
class Tag {
  @JsonKey(name: 'i')
  String id;
  @JsonKey(name: 'n')
  String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
