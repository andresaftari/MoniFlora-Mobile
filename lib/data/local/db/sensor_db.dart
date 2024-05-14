import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:skripsyit/data/local/model/sensor.dart';

class SensorDB {
  static final Box<Sensor> sensorBox = Hive.box<Sensor>('sensors');

  static Future<void> init() async => await Hive.openBox<Sensor>('sensors');

  static Future<void> insertSensor(Sensor sensor) async =>
      await sensorBox.add(sensor);

  static Sensor? fetchLatestSensor(String uuid) =>
      sensorBox.values.toList().firstWhereOrNull((e) => uuid == e.uuid);
}
