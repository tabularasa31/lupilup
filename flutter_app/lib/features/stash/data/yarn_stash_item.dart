enum YarnType { skein, bobbin, blend }

enum YarnSource { manual, scan, ravelry }

class YarnStashItem {
  const YarnStashItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.source,
    required this.createdAt,
    this.brand,
    this.name,
    this.colorName,
    this.colorHex,
    this.fiberContent,
    this.lengthMPer100g,
    this.currentWeightG,
    this.originalWeightG,
    this.lot,
    this.parentIds = const [],
  });

  final String id;
  final String userId;
  final YarnType type;
  final YarnSource source;
  final DateTime createdAt;
  final String? brand;
  final String? name;
  final String? colorName;
  final String? colorHex;
  final String? fiberContent;
  final int? lengthMPer100g;
  final double? currentWeightG;
  final double? originalWeightG;
  final String? lot;
  final List<String> parentIds;

  String get title {
    final brandPart = (brand ?? '').trim();
    final namePart = (name ?? '').trim();
    if (brandPart.isEmpty && namePart.isEmpty) return 'Unnamed yarn';
    if (brandPart.isEmpty) return namePart;
    if (namePart.isEmpty) return brandPart;
    return '$brandPart $namePart';
  }

  factory YarnStashItem.fromMap(Map<String, dynamic> map) {
    return YarnStashItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: YarnType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => YarnType.skein,
      ),
      source: YarnSource.values.firstWhere(
        (value) => value.name == map['source'],
        orElse: () => YarnSource.manual,
      ),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      brand: map['brand'] as String?,
      name: map['name'] as String?,
      colorName: map['color_name'] as String?,
      colorHex: map['color_hex'] as String?,
      fiberContent: map['fiber_content'] as String?,
      lengthMPer100g: (map['length_m_per_100g'] as num?)?.toInt(),
      currentWeightG: (map['current_weight_g'] as num?)?.toDouble(),
      originalWeightG: (map['original_weight_g'] as num?)?.toDouble(),
      lot: map['lot'] as String?,
      parentIds: ((map['parent_ids'] as List<dynamic>?) ?? const [])
          .map((value) => value.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'brand': brand,
      'name': name,
      'color_name': colorName,
      'color_hex': colorHex,
      'fiber_content': fiberContent,
      'length_m_per_100g': lengthMPer100g,
      'current_weight_g': currentWeightG,
      'original_weight_g': originalWeightG,
      'lot': lot,
      'parent_ids': parentIds,
      'source': source.name,
    };
  }

  YarnStashItem copyWith({
    String? id,
    String? userId,
    YarnType? type,
    YarnSource? source,
    DateTime? createdAt,
    String? brand,
    String? name,
    String? colorName,
    String? colorHex,
    String? fiberContent,
    int? lengthMPer100g,
    double? currentWeightG,
    double? originalWeightG,
    String? lot,
    List<String>? parentIds,
  }) {
    return YarnStashItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      colorName: colorName ?? this.colorName,
      colorHex: colorHex ?? this.colorHex,
      fiberContent: fiberContent ?? this.fiberContent,
      lengthMPer100g: lengthMPer100g ?? this.lengthMPer100g,
      currentWeightG: currentWeightG ?? this.currentWeightG,
      originalWeightG: originalWeightG ?? this.originalWeightG,
      lot: lot ?? this.lot,
      parentIds: parentIds ?? this.parentIds,
    );
  }
}

class StashFilter {
  const StashFilter({
    this.sources = const {},
    this.types = const {},
    this.search = '',
  });

  final Set<YarnSource> sources;
  final Set<YarnType> types;
  final String search;

  bool matches(YarnStashItem item) {
    final normalizedSearch = search.trim().toLowerCase();
    final sourceAllowed = sources.isEmpty || sources.contains(item.source);
    final typeAllowed = types.isEmpty || types.contains(item.type);
    final searchAllowed = normalizedSearch.isEmpty ||
        [
          item.brand,
          item.name,
          item.colorName,
          item.fiberContent,
          item.lot,
        ].whereType<String>().any(
          (value) => value.toLowerCase().contains(normalizedSearch),
        );
    return sourceAllowed && typeAllowed && searchAllowed;
  }
}

