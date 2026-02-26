import 'package:json_annotation/json_annotation.dart';

part 'AssetGroup.g.dart';

@JsonSerializable()
class AssetGroup {
  @JsonKey(name: 'i')
  String id;
  @JsonKey(name: 'n')
  String name;

  AssetGroup({required this.id, required this.name});

  factory AssetGroup.fromJson(Map<String, dynamic> json) => _$AssetGroupFromJson(json);
  Map<String, dynamic> toJson() => _$AssetGroupToJson(this);
}
