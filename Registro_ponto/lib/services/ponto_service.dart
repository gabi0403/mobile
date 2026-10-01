import 'package:geolocator/geolocator.dart';

import '../models/local_user.dart';
import 'local_database.dart';

class PontoException implements Exception {
  const PontoException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PointReceipt {
  const PointReceipt({
    required this.distanceMeters,
    required this.registeredAt,
  });

  final double distanceMeters;
  final DateTime registeredAt;
}

class PontoService {
  static const allowedRadiusMeters = 100.0;
  static final _workplaceLatitude = double.tryParse(
    const String.fromEnvironment(
      'WORKPLACE_LATITUDE',
      defaultValue: '-22.658214',
    ),
  );
  static final _workplaceLongitude = double.tryParse(
    const String.fromEnvironment(
      'WORKPLACE_LONGITUDE',
      defaultValue: '-47.345009',
    ),
  );

  static bool get workplaceConfigured =>
      _workplaceLatitude != null &&
      _workplaceLongitude != null &&
      _workplaceLatitude! >= -90 &&
      _workplaceLatitude! <= 90 &&
      _workplaceLongitude! >= -180 &&
      _workplaceLongitude! <= 180;

  static bool isWithinAllowedRadius(double distanceMeters) =>
      distanceMeters <= allowedRadiusMeters;

  Future<PointReceipt> registerPoint(LocalUser user) async {
    if (!workplaceConfigured) {
      throw const PontoException(
        'O local de trabalho ainda não foi configurado. Consulte o README.',
      );
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const PontoException(
        'Ative o GPS/localização do aparelho para registrar o ponto.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const PontoException(
        'A permissão de localização foi negada. Autorize para registrar o ponto.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PontoException(
        'A localização está bloqueada nas configurações do aparelho.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
    if (position.accuracy > allowedRadiusMeters) {
      throw PontoException(
        'O GPS está impreciso (${position.accuracy.round()} m). '
        'Tente novamente em um local aberto.',
      );
    }

    final distance = Geolocator.distanceBetween(
      _workplaceLatitude!,
      _workplaceLongitude!,
      position.latitude,
      position.longitude,
    );
    if (!isWithinAllowedRadius(distance)) {
      throw PontoException(
        'Você está a ${distance.round()} m do local de trabalho. '
        'O limite para registrar é 100 m.',
      );
    }

    final registeredAt = DateTime.now();
    final date =
        '${registeredAt.year}-'
        '${registeredAt.month.toString().padLeft(2, '0')}-'
        '${registeredAt.day.toString().padLeft(2, '0')}';
    final time =
        '${registeredAt.hour.toString().padLeft(2, '0')}:'
        '${registeredAt.minute.toString().padLeft(2, '0')}:'
        '${registeredAt.second.toString().padLeft(2, '0')}';

    await LocalDatabase.instance.insertPoint(
      user: user,
      date: date,
      time: time,
      registeredAt: registeredAt,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      distanceMeters: distance,
    );

    return PointReceipt(distanceMeters: distance, registeredAt: registeredAt);
  }
}
