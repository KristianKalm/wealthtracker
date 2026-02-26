class Asset {
  String id;
  String name;
  List<String> tagIds;
  String? groupId;
  Map<String, double> monthlyValues;
  int? updatedAt;

  Asset({required this.id, this.name = "", this.tagIds = const [], this.groupId, this.monthlyValues = const {}, this.updatedAt});

  factory Asset.fromJson(Map<String, dynamic> json) {
    // Detect old per-month format and reject it
    if (json.containsKey('ym')) {
      throw FormatException('Old per-month asset format detected, skipping');
    }

    final mvRaw = json['mv'];
    Map<String, double> mv = {};
    if (mvRaw is Map) {
      mv = mvRaw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }

    return Asset(
      id: json['i'] as String,
      name: json['n'] as String? ?? "",
      tagIds: (json['t'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      groupId: json['g'] as String?,
      monthlyValues: mv,
      updatedAt: (json['ua'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'i': id,
    'n': name,
    't': tagIds,
    'g': groupId,
    'mv': monthlyValues,
    'ua': updatedAt,
  };
}
