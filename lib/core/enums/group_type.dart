enum GroupType {
  trip,
  home,
  friends,
  custom;

  String get displayName {
    switch (this) {
      case GroupType.trip:
        return 'Trip';
      case GroupType.home:
        return 'Home';
      case GroupType.friends:
        return 'Friends';
      case GroupType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case GroupType.trip:
        return '✈️';
      case GroupType.home:
        return '🏠';
      case GroupType.friends:
        return '👥';
      case GroupType.custom:
        return '📁';
    }
  }
}
