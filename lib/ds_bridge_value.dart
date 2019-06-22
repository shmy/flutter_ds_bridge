class DsBridgeValue {
  final String title;
  final String url;
  final int progress;
  final bool canGoBack;

  DsBridgeValue({
    this.title,
    this.url,
    this.progress,
    this.canGoBack,
  });

  DsBridgeValue copyWith({
    String title,
    String url,
    int progress,
    bool canGoBack,
  }) {
    return DsBridgeValue(
      title: title ?? this.title,
      url: url ?? this.url,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
    );
  }
}
