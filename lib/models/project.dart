class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.organization,
    required this.linkLabel,
    required this.linkUrl,
    required this.tags,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    period: json['period'] as String,
    organization: json['organization'] as String,
    linkLabel: json['link_label'] as String,
    linkUrl: json['link_url'] as String,
    tags: List<String>.from(json['tags'] as List? ?? const []),
  );

  final int id;
  final String title;
  final String description;
  final String period;
  final String organization;
  final String linkLabel;
  final String linkUrl;
  final List<String> tags;
}
