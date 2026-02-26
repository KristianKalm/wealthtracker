class AssetUiModel {
  int? yearMonth;
  String? name;
  num? value;
  num? change;
  num? lastMonthValue;
  num? percent;
  List<String> tagIds;
  String? groupId;
  bool suggestion = false;
  bool addNew = false;

  AssetUiModel({this.yearMonth, this.name, this.value, this.change, this.lastMonthValue, this.percent, this.tagIds = const [], this.groupId, this.suggestion = false, this.addNew = false});
}
