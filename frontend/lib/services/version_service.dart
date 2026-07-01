import 'package:blog_app/services/api_service.dart';

/// Stores version information returned from the backend.
class VersionInfo {
  final String currentVersion;
  final String minVersion;
  final bool forceUpgrade;
  final String changelog;
  final Map<String, String?> storeUrl;
  final int buildNumber;
  final String releaseDate;

  const VersionInfo({
    required this.currentVersion,
    required this.minVersion,
    required this.forceUpgrade,
    required this.changelog,
    required this.storeUrl,
    required this.buildNumber,
    required this.releaseDate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) => VersionInfo(
    currentVersion: json['currentVersion'] as String? ?? '1.0.0',
    minVersion: json['minVersion'] as String? ?? '1.0.0',
    forceUpgrade: json['forceUpgrade'] as bool? ?? false,
    changelog: json['changelog'] as String? ?? '',
    storeUrl: {
      'android': (json['storeUrl'] as Map<String, dynamic>?)?['android'] as String?,
      'ios': (json['storeUrl'] as Map<String, dynamic>?)?['ios'] as String?,
    },
    buildNumber: json['buildNumber'] as int? ?? 1,
    releaseDate: json['releaseDate'] as String? ?? '',
  );
}

/// Compares semantic version strings: returns -1 if a < b, 0 if equal, 1 if a > b
int compareVersions(String a, String b) {
  final aParts = a.split('.').map(int.parse).toList();
  final bParts = b.split('.').map(int.parse).toList();
  for (int i = 0; i < 3; i++) {
    final av = i < aParts.length ? aParts[i] : 0;
    final bv = i < bParts.length ? bParts[i] : 0;
    if (av < bv) return -1;
    if (av > bv) return 1;
  }
  return 0;
}

/// The app's current version — must match pubspec.yaml `version`.
/// Format: MAJOR.MINOR.PATCH (drop +buildNumber)
const String kAppVersion = '1.0.0';
const int kAppBuildNumber = 1;

class VersionService {
  /// Fetches version info from `/api/version`.
  /// Returns null on network failure (fail-open: app should proceed).
  Future<VersionInfo?> checkVersion() async {
    try {
      final response = await ApiService.instance.dio.get('/version');
      if (response.statusCode == 200 && response.data != null) {
        return VersionInfo.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      // Network unreachable or server down — fail silently, app continues
      return null;
    }
  }

  /// Returns true if the installed version is below the minimum required.
  bool requiresForceUpgrade(VersionInfo info) {
    if (info.forceUpgrade) return true;
    return compareVersions(kAppVersion, info.minVersion) < 0;
  }

  /// Returns true if there's a newer version available (soft update).
  bool hasSoftUpdate(VersionInfo info) {
    return compareVersions(kAppVersion, info.currentVersion) < 0;
  }
}
