import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

class RouteDistanceService {
  static Future<List<double>> getLegDistancesKm(
    List<LatLng> waypoints,
  ) async {
    if (waypoints.length < 2) {
      throw ArgumentError('At least two route points are required.');
    }

    final String coordinates = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');
    final Uri uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$coordinates',
      {'overview': 'false', 'steps': 'false'},
    );
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    const Duration requestTimeout = Duration(seconds: 20);

    try {
      final HttpClientRequest request =
          await client.getUrl(uri).timeout(requestTimeout);
      request.headers.set(HttpHeaders.userAgentHeader, 'women_safety_app');
      final HttpClientResponse response =
          await request.close().timeout(requestTimeout);
      final String body =
          await response.transform(utf8.decoder).join().timeout(requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Routing service returned ${response.statusCode}.');
      }

      final Map<String, dynamic> data =
          jsonDecode(body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') {
        throw const FormatException('No drivable route was found.');
      }

      final List<dynamic> routes = data['routes'] as List<dynamic>;
      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final List<dynamic> legs = route['legs'] as List<dynamic>;
      return legs
          .map((leg) =>
              ((leg as Map<String, dynamic>)['distance'] as num) / 1000.0)
          .toList();
    } finally {
      client.close(force: true);
    }
  }
}
