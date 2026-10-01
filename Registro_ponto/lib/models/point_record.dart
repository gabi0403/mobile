class PointRecord {
  const PointRecord({
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  final String date;
  final String time;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  factory PointRecord.fromMap(Map<String, Object?> row) => PointRecord(
    date: row['date']! as String,
    time: row['time']! as String,
    latitude: (row['latitude']! as num).toDouble(),
    longitude: (row['longitude']! as num).toDouble(),
    distanceMeters: (row['distance_meters']! as num).toDouble(),
  );
}
