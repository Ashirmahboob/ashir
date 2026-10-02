// lib/services/fare_calculator_service.dart
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FareCalculatorService {


  /// Calculates straight-line distance in Kilometers
  static double calculateDistanceInKm(LatLng pickup, LatLng dropoff) {
    return Geolocator.distanceBetween(
      pickup.latitude, pickup.longitude,
      dropoff.latitude, dropoff.longitude,
    ) / 1000.0;
  }

  /// Estimates travel time in minutes assuming average urban speed (25 km/h)
  static double estimateDurationInMinutes(double distanceInKm) {
    const double avgSpeedKmPerHour = 25.0;
    return (distanceInKm / avgSpeedKmPerHour) * 60;
  }

  /// Calculates baseline fare for vehicle type
  static double calculateRecommendedFare({
    required LatLng pickup,
    required LatLng dropoff,
    required String vehicleType,
    bool isFirstRideDiscount = false,
  }) {
    final double distanceInKm = calculateDistanceInKm(pickup, dropoff);
    final double durationInMinutes = estimateDurationInMinutes(distanceInKm);

    double baseFare = 50.0;
    double ratePerKm = 30.0;
    double ratePerMinute = 2.0;

    switch (vehicleType.toLowerCase()) {
      case 'scooty':
        baseFare = 40.0;
        ratePerKm = 25.0;
        break;
      case 'rickshaw':
        baseFare = 60.0;
        ratePerKm = 35.0;
        break;
      case 'car':
        baseFare = 100.0;
        ratePerKm = 50.0;
        ratePerMinute = 4.0;
        break;
    }

    double totalFare = baseFare + (distanceInKm * ratePerKm) + (durationInMinutes * ratePerMinute);

    if (isFirstRideDiscount) {
      totalFare *= 0.80; // 20% discount
    }

    // Round to nearest 10 for clean currency display
    return (totalFare / 10).round() * 10.0;
  }
}