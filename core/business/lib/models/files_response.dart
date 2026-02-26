class FileData {
  final String name;
  final String data;

  FileData({
    required this.name,
    required this.data,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      name: json['name'] as String,
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'data': data,
    };
  }
}

class FilesResponse {
  final List<FileData> files;
  final int total;
  final int start;
  final int limit;
  final bool hasMore;

  FilesResponse({
    required this.files,
    required this.total,
    required this.start,
    required this.limit,
    required this.hasMore,
  });

  factory FilesResponse.fromJson(Map<String, dynamic> json) {
    return FilesResponse(
      files: (json['files'] as List<dynamic>)
          .map((item) => FileData.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      start: json['start'] as int,
      limit: json['limit'] as int,
      hasMore: json['has_more'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'files': files.map((f) => f.toJson()).toList(),
      'total': total,
      'start': start,
      'limit': limit,
      'has_more': hasMore,
    };
  }
}
