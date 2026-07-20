/// Arguments when opening [RoomDesignerScreen] from template setup or elsewhere.
class RoomDesignerArgs {
  final double widthFt;
  final double heightFt;

  /// Optional preset layout: `living`, `bedroom`, `kitchen`.
  final String? templateId;

  final String roomTitle;

  const RoomDesignerArgs({
    required this.widthFt,
    required this.heightFt,
    this.templateId,
    required this.roomTitle,
  });
}

/// Passed to [TemplateRoomSetupScreen] from template picker.
class TemplateSetupArgs {
  final String templateId;
  final String title;
  final String? subtitle;

  const TemplateSetupArgs({
    required this.templateId,
    required this.title,
    this.subtitle,
  });
}
