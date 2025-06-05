// import 'package:permission_handler/permission_handler.dart';

// class PermissionHelper {
//   static Future<bool> requestLocationPermissions() async {
//     var status = await Permission.location.request();
//     if (status.isDenied) {
//       return false;
//     }
//     if (status.isPermanentlyDenied) {
//       await openAppSettings();
//       return false;
//     }
//     return true;
//   }
// }
