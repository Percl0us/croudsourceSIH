import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Request Camera permission
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Request Gallery/Storage permission
  static Future<bool> requestGallery() async {
    // ✅ Android → Storage, iOS → Photos
    final Permission perm = Permission.storage;
    final status = await perm.status;
    if (status.isGranted) return true;

    final result = await perm.request();
    return result.isGranted;
  }

  /// Request Location permission
  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    final result = await Permission.locationWhenInUse.request();
    return result.isGranted;
  }

  /// Open app settings if permission is permanently denied
  static Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}
