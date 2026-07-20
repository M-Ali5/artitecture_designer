class DesignProject {
  const DesignProject({
    required this.id,
    required this.type,
    required this.style,
    required this.prompt,
    required this.generatedImageUrl,
    required this.referenceImageUrl,
    required this.createdAtIso,
  });

  final String id;
  final String type;
  final String style;
  final String prompt;
  final String generatedImageUrl;
  final String referenceImageUrl;
  final String createdAtIso;

  factory DesignProject.fromMap(String id, Map<String, dynamic> map) {
    return DesignProject(
      id: id,
      type: map['type']?.toString() ?? 'interior',
      style: map['style']?.toString() ?? '',
      prompt: map['prompt']?.toString() ?? '',
      generatedImageUrl: map['generatedImageUrl']?.toString() ?? '',
      referenceImageUrl: map['referenceImageUrl']?.toString() ?? '',
      createdAtIso: map['createdAt']?.toString() ?? '',
    );
  }
}

class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.content,
    required this.createdAtIso,
  });

  final String role;
  final String content;
  final String createdAtIso;

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'createdAt': createdAtIso,
    };
  }
}
