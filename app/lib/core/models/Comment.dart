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
  @JsonKey(name: 'sn')
  double? netSalary;
  @JsonKey(name: 'sg')
  double? grossSalary;
  @JsonKey(name: 'sb')
  double? bonusNet;
  @JsonKey(name: 'sp')
  String? position;
  @JsonKey(name: 'sco')
  String? company;
  @JsonKey(name: 'sc')
  String? salaryComment;

  bool get hasSalaryData =>
      netSalary != null || grossSalary != null || bonusNet != null ||
      position != null || company != null;

  Comment({
    required this.id,
    required this.yearMonth,
    this.comment = "",
    this.updatedAt,
    this.netSalary,
    this.grossSalary,
    this.bonusNet,
    this.position,
    this.company,
    this.salaryComment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
