class SensorResponse {
  final String? uuid;
  final int light;
  final int conductivity;
  final int moisture;
  final double temperature;
  final String localName;
  final String bioName;
  final int dateTime;

  SensorResponse({
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
        'uuid': uuid,
        'light': light,
        'temperature': temperature,
        'conductivity': conductivity,
        'moisture': moisture,
        'localname': localName,
        'bioname': bioName,
        'timestamp': dateTime,
      };

  static SensorResponse fromJson(Map<dynamic, dynamic> json) => SensorResponse(
        light: json['light'],
        temperature: json['temperature'],
        conductivity: json['conductivity'],
        moisture: json['moisture'],
        localName: json['localname'],
        bioName: json['bioname'],
        dateTime: json['timestamp'],
      );

  @override
  String toString() {
    return '''
      uuid: $uuid,
      light: $light,
      temperature: $temperature,
      conductivity: $conductivity,
      moisture: $moisture,
      localName: $localName,
      bioName: $bioName,
      dateTime: $dateTime
    ''';
  }
}
