class TwoStepDesignArgs {
  const TwoStepDesignArgs({
    required this.initialType,
    this.initialStyle,
    this.initialColor,
    this.initialPrompt,
  });

  final String initialType;
  final String? initialStyle;
  final String? initialColor;
  final String? initialPrompt;
}
