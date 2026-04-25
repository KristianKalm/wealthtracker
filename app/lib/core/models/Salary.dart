import 'package:json_annotation/json_annotation.dart';

part 'Salary.g.dart';

@JsonSerializable()
class Salary {
  @JsonKey(name: 'i')
  String id;
  @JsonKey(name: 'ym')
  int yearMonth;
  @JsonKey(name: 'n')
  double? netSalary;
  @JsonKey(name: 'g')
  double? grossSalary;
  @JsonKey(name: 'b')
  double? bonusNet;
  @JsonKey(name: 'p')
  String? position;
  @JsonKey(name: 'c')
  String? comment;
  @JsonKey(name: 'ua')
  int? updatedAt;

  Salary({
    required this.id,
    required this.yearMonth,
    this.netSalary,
    this.grossSalary,
    this.bonusNet,
    this.position,
    this.comment,
    this.updatedAt,
  });

  factory Salary.fromJson(Map<String, dynamic> json) => _$SalaryFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryToJson(this);
}
