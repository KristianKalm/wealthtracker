import 'package:json_annotation/json_annotation.dart';

part 'Comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(name: 'i')
  String id;
  @JsonKey(name: 'ym')
  int yearMonth;
  @JsonKey(name: 'c')
  String comment;
  @JsonKey(name: 'ua')
  int? updatedAt;

  Comment({required this.id, required this.yearMonth, this.comment = "", this.updatedAt});

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
