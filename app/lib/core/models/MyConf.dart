import 'package:json_annotation/json_annotation.dart';

import 'AssetGroup.dart';
import 'Tag.dart';

part 'MyConf.g.dart';

/// Custom configuration parser for specific config types
typedef ConfigParser<T> = T Function(dynamic json);

/// Hybrid configuration object that stores:
/// - Core fields: tags, theme settings
/// - Custom configs: flexible map for additional configurations
@JsonSerializable(explicitToJson: true)
class MyConf {
  @JsonKey(name: 'i')
  String id; // Always 'my_config'

  @JsonKey(name: 'isDarkTheme')
  bool isDarkTheme;

  @JsonKey(name: 'tags', defaultValue: [])
  List<Tag> tags;

  @JsonKey(name: 'assetGroups', defaultValue: [])
  List<AssetGroup> assetGroups;

  /// Flexible map for custom configurations
  /// Each key can have its own parsing logic
  @JsonKey(name: 'customConfigs')
  Map<String, dynamic> customConfigs;

  @JsonKey(name: 'ua')
  int? updatedAt;

  MyConf({
    required this.id,
    required this.isDarkTheme,
    required this.tags,
    required this.assetGroups,
    required this.customConfigs,
    this.updatedAt,
  });

  factory MyConf.fromJson(Map<String, dynamic> json) => _$MyConfFromJson(json);
  Map<String, dynamic> toJson() => _$MyConfToJson(this);

  factory MyConf.empty() => MyConf(
        id: 'my_config',
        isDarkTheme: true,
        tags: [],
        assetGroups: [],
        customConfigs: {},
        updatedAt: null,
      );

  /// Get a custom config value with type parsing
  T? getCustomConfig<T>(String key, ConfigParser<T> parser) {
    final value = customConfigs[key];
    if (value == null) return null;
    return parser(value);
  }

  /// Set a custom config value
  void setCustomConfig(String key, dynamic value) {
    customConfigs[key] = value;
  }

  /// Remove a custom config
  void removeCustomConfig(String key) {
    customConfigs.remove(key);
  }

  /// Copy with method for immutable updates
  MyConf copyWith({
    String? id,
    bool? isDarkTheme,
    List<Tag>? tags,
    List<AssetGroup>? assetGroups,
    Map<String, dynamic>? customConfigs,
    int? updatedAt,
  }) {
    return MyConf(
      id: id ?? this.id,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      tags: tags ?? this.tags,
      assetGroups: assetGroups ?? this.assetGroups,
      customConfigs: customConfigs ?? this.customConfigs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Example custom config parsers
class MyConfParsers {
  /// Parse a list of strings
  static List<String> parseStringList(dynamic json) {
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Parse a simple key-value map
  static Map<String, String> parseStringMap(dynamic json) {
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {};
  }

  /// Parse an integer value
  static int parseInt(dynamic json) {
    if (json is int) return json;
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  /// Parse a boolean value
  static bool parseBool(dynamic json) {
    if (json is bool) return json;
    if (json is String) return json.toLowerCase() == 'true';
    return false;
  }

  /// Parse a double value
  static double parseDouble(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0.0;
  }
}
