class Sensor {
  String? uuid;
  final int light;
  final int conductivity;
  final int moisture;
  final double temperature;
  final String localName;
  final String bioName;
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
