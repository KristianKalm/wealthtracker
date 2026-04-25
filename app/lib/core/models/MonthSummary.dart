import 'AssetUiModel.dart';

class MonthSummary {
  num currentMonthSum = 0;
  num lastMonthSum = 0;
  num percent = 0;
  num change = 0;
  String? comment;
  List<AssetUiModel> assets = [];
  List<AssetUiModel> suggestions = [];
}
 