/// Compares dotted version strings (e.g. `1.9.0` vs `1.10.0`).
///
/// Returns negative if [a] < [b], zero if equal, positive if [a] > [b].
/// Non-numeric segments are treated as `0`.
int compareVersions(String a, String b) {
  final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final len = aParts.length > bParts.length ? aParts.length : bParts.length;
  for (var i = 0; i < len; i++) {
    final av = i < aParts.length ? aParts[i] : 0;
    final bv = i < bParts.length ? bParts[i] : 0;
    if (av != bv) return av.compareTo(bv);
  }
  return 0;
}

/// Whether [storeVersion] is strictly newer than [currentVersion].
bool isStoreVersionNewer(String currentVersion, String storeVersion) {
  return compareVersions(currentVersion, storeVersion) < 0;
}
