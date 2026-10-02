// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {


  /// Checks if driver is within target radius (e.g., 5.0 km) from passenger
  static bool isDriverWithinRadius({
    required double passengerLat,
    required double passengerLng,
    required double driverLat,
    required double driverLng,
    double radiusInKm = 5.0,
  }) {
    final double distanceInMeters = Geolocator.distanceBetween(
      passengerLat, passengerLng,
      driverLat, driverLng,
    );
    return (distanceInMeters / 1000.0) <= radiusInKm;
  }
}