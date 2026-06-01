enum SplitType {
  equal,
  exact,
  percentage;

  String get displayName {
    switch (this) {
      case SplitType.equal:
        return 'Equal';
      case SplitType.exact:
        return 'Exact';
      case SplitType.percentage:
        return 'Percentage';
    }
  }
}
