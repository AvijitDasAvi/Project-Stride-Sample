import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Ensure location service and permissions are enabled/granted.
  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Position stream with distance filter to reduce noise
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, 
      ),
    );
  }

  /// Get current position if permission granted
  Future<Position?> getCurrentPosition() async {
    bool permissionGranted = await ensurePermission();
    if (!permissionGranted) return null;

    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }
}
