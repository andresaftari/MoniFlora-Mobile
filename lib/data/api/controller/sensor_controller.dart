import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:skripsyit/data/local/db/sensor_db.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/utils/shared_prefs.dart';

class SensorController extends GetxController {
  late Box<Sensor> _sensorBox;

  final SharedPreferenceService _sharedPrefs = SharedPreferenceService();
  final DatabaseReference ref = FirebaseDatabase.instance.ref('/');

  Rx<Sensor?> sensorObs = Rx<Sensor?>(null);

  RxDouble temperatureObs = 0.0.obs;
  RxInt intensityObs = 0.obs;
  RxInt conductivityObs = 0.obs;
  RxInt moistureObs = 0.obs;

  @override
  void onInit() async {
    _sensorBox = SensorDB.sensorBox;
    await getSingleLatestValue();

    super.onInit();
  }

  Future getSingleLatestValue() async {
    final snap = await ref.child('sensor').limitToLast(1).get();

    if (snap.exists) {
      var uuid = snap.children.last.key;
      var data = snap.children.last.value;

      Map<String, dynamic> dataDecode = json.decode(jsonEncode(data));

      Sensor sensor = Sensor(
        uuid: uuid,
        light: dataDecode['light'],
        temperature: dataDecode['temperature'],
        conductivity: dataDecode['conductivity'],
        moisture: dataDecode['moisture'],
        localName: dataDecode['localname'],
        bioName: dataDecode['bioname'],
        dateTime: DateFormat('dd MMMM yyyy HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(dataDecode['timestamp'] * 1000),
        ),
      );

      _sharedPrefs.putString('sensor_uuid', uuid.toString());

      if (SensorDB.fetchLatestSensor(uuid!) == null) {
        await SensorDB.insertSensor(sensor);
      } else {
        log(
          SensorDB.fetchLatestSensor(uuid).toString(),
          name: 'sensor-db',
        );

        await SensorDB.updateSensor(
          _sensorBox.values.toList().indexWhere((e) => e.uuid == uuid),
          sensor,
        );
      }

      temperatureObs.value = sensor.temperature;
      intensityObs.value = sensor.light;
      conductivityObs.value = sensor.conductivity;
      moistureObs.value = sensor.moisture;

      return sensor;
    }
  }

  Sensor? fetchLatestData(String uuid) {
    return SensorDB.fetchLatestSensor(uuid);
  }
}
