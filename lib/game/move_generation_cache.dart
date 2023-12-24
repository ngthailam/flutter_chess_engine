class MoveGenerationCache {
  static const MoveGenerationCache _singleton = MoveGenerationCache._internal();

  factory MoveGenerationCache() {
    return _singleton;
  }

  const MoveGenerationCache._internal();

  static void invalidate() {
    // Clear cache
  }
}
