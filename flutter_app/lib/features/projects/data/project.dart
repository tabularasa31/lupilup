enum ProjectStatus { active, finished, onHold }

class Project {
  const Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.currentRow,
    required this.yarnIds,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final ProjectStatus status;
  final int currentRow;
  final List<String> yarnIds;
  final DateTime createdAt;

  factory Project.fromMap(Map<String, dynamic> map) {
    final rawStatus = map['status'] as String? ?? 'active';
    return Project(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String? ?? '',
      status: switch (rawStatus) {
        'finished' => ProjectStatus.finished,
        'on_hold' => ProjectStatus.onHold,
        _ => ProjectStatus.active,
      },
      currentRow: (map['current_row'] as num?)?.toInt() ?? 0,
      yarnIds: ((map['yarn_ids'] as List<dynamic>?) ?? const [])
          .map((value) => value.toString())
          .toList(),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'status': switch (status) {
        ProjectStatus.active => 'active',
        ProjectStatus.finished => 'finished',
        ProjectStatus.onHold => 'on_hold',
      },
      'current_row': currentRow,
      'yarn_ids': yarnIds,
    };
  }

  Project copyWith({
    String? title,
    ProjectStatus? status,
    int? currentRow,
    List<String>? yarnIds,
  }) {
    return Project(
      id: id,
      userId: userId,
      title: title ?? this.title,
      status: status ?? this.status,
      currentRow: currentRow ?? this.currentRow,
      yarnIds: yarnIds ?? this.yarnIds,
      createdAt: createdAt,
    );
  }
}

