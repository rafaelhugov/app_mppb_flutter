class ForceUpdateState {
  final bool isForceUpdateRequired;
  final int minBuild;
  final int currentBuild;
  final String storeUrl;
  final String message;

  const ForceUpdateState({
    this.isForceUpdateRequired = false,
    this.minBuild = 0,
    this.currentBuild = 0,
    this.storeUrl = '',
    this.message = '',
  });

  ForceUpdateState copyWith({
    bool? isForceUpdateRequired,
    int? minBuild,
    int? currentBuild,
    String? storeUrl,
    String? message,
  }) {
    return ForceUpdateState(
      isForceUpdateRequired:
          isForceUpdateRequired ?? this.isForceUpdateRequired,
      minBuild: minBuild ?? this.minBuild,
      currentBuild: currentBuild ?? this.currentBuild,
      storeUrl: storeUrl ?? this.storeUrl,
      message: message ?? this.message,
    );
  }
}

