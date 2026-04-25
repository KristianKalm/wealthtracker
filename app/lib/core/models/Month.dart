import 'package:json_annotation/json_annotation.dart';

part 'Month.g.dart';

@JsonSerializable()
class Month {
  @JsonKey(name: 'i')
  String id;
  @JsonKey(name: 'ym')
  int yearMonth;
  @JsonKey(name: 'c')
  String comment;
  @JsonKey(name: 'ua')
  int? updatedAt;
  @JsonKey(name: 'sg')
  double? salary;
  @JsonKey(name: 'sb')
  double? bonus;
  @JsonKey(name: 'sp')
  String? position;
  @JsonKey(name: 'sco')
  String? company;
  @JsonKey(name: 'sc')
  String? salaryComment;

  bool get hasSalaryData =>
      salary != null || bonus != null ||
      position != null || company != null;

  Month({
    required this.id,
    required this.yearMonth,
    this.comment = "",
    this.updatedAt,
    this.salary,
    this.bonus,
    this.position,
    this.company,
    this.salaryComment,
  });

  factory Month.fromJson(Map<String, dynamic> json) => _$MonthFromJson(json);
  Map<String, dynamic> toJson() => _$MonthToJson(this);
}
