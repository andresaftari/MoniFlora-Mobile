import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:random_forest/random_forest.dart';
import 'package:skripsyit/data/local/db/sensor_db.dart';
import 'package:skripsyit/data/local/fuzzy_logic.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/utils/shared_prefs.dart';

class SensorController extends GetxController {
  late Box<Sensor> _sensorBox;

  final SharedPreferenceService _sharedPrefs = SharedPreferenceService();
  final RandomForest forest = RandomForest(randomState: 42);
  final DatabaseReference ref = FirebaseDatabase.instance.ref('/');
  final FuzzyLogic fuzzyLogic = FuzzyLogic();

  Rx<Sensor?> sensorObs = Rx<Sensor?>(null);

  final RxList<dynamic> outputs = List.empty(growable: true).obs;
  RxBool isLoading = false.obs;

  RxDouble temperatureObs = 0.0.obs;
  RxInt intensityObs = 0.obs;
  RxInt conductivityObs = 0.obs;
  RxInt moistureObs = 0.obs;

  RxString conditionObs = ''.obs;

  @override
  void onInit() async {
    _sensorBox = SensorDB.sensorBox;

    await trainRF();
    await getSingleLatestValue();
    await predictLatestData();

    super.onInit();
  }

  Future<void> trainRF() async {
    try {
      final List<Map<String, num>> trainingData = [];
      final List<String> trainingTarget = [];

      final data = _sensorBox.values.toList();

      for (final sensor in data) {
        trainingData.add({
          'temperature': sensor.temperature.toDouble(),
          'light': sensor.light.toDouble(),
          'conductivity': sensor.conductivity.toDouble(),
          'moisture': sensor.moisture.toDouble(),
        });

        trainingTarget.add(determineCondition(sensor));
      }

      forest.fit(trainingData, trainingTarget);
      log('Model training completed', name: 'rf-model');
    } catch (e) {
      log('Error training rf: $e', name: 'rf-model');
    }
  }

  String determineCondition(Sensor sensor) {
    String tempClass =
        fuzzyLogic.classifyTemperature(sensor.temperature.toDouble());
    String lightClass = fuzzyLogic.classifyIntensity(sensor.light);
    String ecClass = fuzzyLogic.classifyEC(sensor.conductivity);
    String moistureClass = fuzzyLogic.classifyMoisture(sensor.moisture);

    if (tempClass == 'Optimal' &&
        lightClass == 'Optimal' &&
        ecClass == 'Optimal' &&
        moistureClass == 'Optimal') {
      return 'Optimal';
    } else if (tempClass == 'Extreme' ||
        lightClass == 'Extreme' ||
        ecClass == 'Extreme' ||
        moistureClass == 'Extreme') {
      return 'Extreme';
    } else {
      return 'Caution';
    }
  }

  Future<void> predictLatestData() async {
    try {
      final Sensor? latestSensor = await getSingleLatestValue();

      if (latestSensor != null) {
        final Map<String, num> inputData = {
          'temperature': latestSensor.temperature.toDouble(),
          'light': latestSensor.light.toDouble(),
          'conductivity': latestSensor.conductivity.toDouble(),
          'moisture': latestSensor.moisture.toDouble(),
        };

        await runInference(inputData);
      } else {
        log('No latest sensor data available for prediction', name: 'rf-model');
      }
    } catch (e) {
      log('Error predicting latest data: $e', name: 'rf-model');
    }
  }

  Future<void> runInference(Map<String, num> inputData) async {
    try {
      final predictList = forest.predict([inputData]);
      final predictOne = predictList.first;

      final predDetail = forest.predictOneDetail(inputData);
      outputs.value = predDetail.entries.map((e) => e.value).toList();

      conditionObs.value = predictOne;

      log('Inputs: $inputData', name: 'rf-model');
      log('Outputs: $outputs', name: 'rf-model');
      log('Prediction: $predictOne', name: 'rf-model');
      log('Prediction details: $predDetail', name: 'rf-model');
    } catch (e) {
      log('failed to load input data: $e', name: 'rf-model');
    }
  }

  Future<Sensor?> getSingleLatestValue() async {
    try {
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
            DateTime.fromMillisecondsSinceEpoch(dataDecode['timestamp']),
          ),
        );

        sensorObs.value = sensor;
        _sharedPrefs.putString('sensor_uuid', uuid.toString());

        if (SensorDB.fetchLatestSensor(uuid!) == null) {
          await SensorDB.insertSensor(sensor);
        } else {
          log(SensorDB.fetchLatestSensor(uuid).toString(), name: 'sensor-db');
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
      } else {
        log('No sensor data found in the database', name: 'sensor-db');
        return null;
      }
    } catch (e) {
      log('Error getting latest sensor value: $e', name: 'sensor-db');
      return null;
    }
  }

  Sensor? fetchLatestData(String uuid) {
    return SensorDB.fetchLatestSensor(uuid);
  }
}
