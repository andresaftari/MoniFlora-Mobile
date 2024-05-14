import 'package:hive/hive.dart';

part 'sensor.g.dart';

@HiveType(typeId: 0)
class Sensor extends HiveObject {
  @HiveField(0)
  String? uuid;
  @HiveField(1)
  final int light;
  @HiveField(2)
  final int conductivity;
  @HiveField(3)
  final int moisture;
  @HiveField(4)
  final double temperature;
  @HiveField(5)
  final String localName;
  @HiveField(6)
  final String bioName;
  @HiveField(7)
  final String dateTime;

  Sensor({
    this.uuid,
    required this.light,
    required this.temperature,
    required this.conductivity,
    required this.moisture,
    required this.localName,
    required this.bioName,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'light': light,
        'temperature': temperature,
        'conductivity': conductivity,
        'moisture': moisture,
        'localName': localName,
        'bioName': bioName,
        'createdAt': dateTime,
      };

  static Sensor fromJson(Map<dynamic, dynamic> json) => Sensor(
        light: json['light'],
        temperature: json['temperature'],
        conductivity: json['conductivity'],
        moisture: json['moisture'],
        localName: json['localname'],
        bioName: json['bioname'],
        dateTime: json['createdAt'],
      );

  @override
  String toString() {
    return '$uuid: $light, $temperature, $conductivity, $moisture, $localName, $bioName, $dateTime';
  }

  // final Timestamp timestamp;
}