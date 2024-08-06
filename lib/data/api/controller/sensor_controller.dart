import 'dart:convert';
import 'dart:developer' as d;
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:retry/retry.dart';
import 'package:skripsyit/data/api/response/predict_response.dart';
import 'package:skripsyit/data/api/response/sensor_response.dart';
import 'package:skripsyit/data/api/service/predict_service.dart';
import 'package:skripsyit/data/local/db/sensor_db.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/utils/shared_prefs.dart';

class SensorController extends GetxController {
  late Box<Sensor> _sensorBox;

  final SharedPreferenceService _sharedPrefs = SharedPreferenceService();
  final DatabaseReference ref = FirebaseDatabase.instance.ref('/');
  final PredictService _predictService = PredictService(Dio());

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
    super.onInit();
  }

  Stream<Prediction> postPrediction({
    required double temperature,
    required double light,
    required double ec,
    required double moisture,
  }) async* {
    late Prediction pred;

    final response = await _predictService.postPredictionParam(
      temperature: temperature,
      light: light,
      ec: ec,
      moisture: moisture,
    );

    response.fold(
      (l) {
        d.log(l.message, name: 'predict');

        pred = Prediction(
          prediction: 'Unknown',
          predictionIndex: 0,
          probability: [],
        );
      },
      (r) {
        conditionObs.value = r.prediction;
        pred = r;
      },
    );

    // log('prediction: $pred', name: 'predict');
    yield pred;
  }

  Stream<List<SensorResponse>> getAllSensor() async* {
    final r = RetryOptions(maxAttempts: 5, delayFactor: Duration(seconds: 2));

    while (true) {
      try {
        // Fetch data and retry on permission error
        final List<SensorResponse> sensors = await r.retry(
          () async {
            final snap = await ref.child('sensor').get();
            List<SensorResponse> sensors = [];

            if (snap.exists) {
              snap.children.forEach((element) {
                var dataDecode = SensorResponse.fromJson(
                  json.decode(jsonEncode(element.value)),
                );

                sensors.add(
                  SensorResponse(
                    uuid: element.key,
                    light: dataDecode.light,
                    temperature: dataDecode.temperature.toDouble(),
                    conductivity: dataDecode.conductivity,
                    moisture: dataDecode.moisture,
                    localName: dataDecode.localName,
                    bioName: dataDecode.bioName,
                    dateTime: dataDecode.dateTime,
                  ),
                );
              });
            } else {
              d.log('Error fetching all sensor from Firebase',
                  name: 'getAllSensor');
            }

            return sensors;
          },
          retryIf: (e) => e.toString().contains(
              'Client doesn\'t have permission to access the desired data.'),
        );

        yield sensors;
        break;
      } catch (e) {
        d.log('Error fetching all sensor value: $e',
            name: 'getAllSensor-failed');
        yield [];
        await Future.delayed(Duration(seconds: 5)); // Wait before retrying
      }
    }
  }

  Stream<Sensor?> getSingleLatestValue() async* {
    try {
      final snap = await ref.child('sensor').limitToLast(1).get();

      if (snap.exists) {
        var uuid = snap.children.last.key;
        var data = snap.children.last.value;

        Map<String, dynamic> dataDecode = json.decode(jsonEncode(data));

        Sensor sensor = Sensor(
          uuid: uuid,
          light: dataDecode['light'],
          temperature: dataDecode['temperature'].toDouble(),
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
          await SensorDB.updateSensor(
            _sensorBox.values.toList().indexWhere((e) => e.uuid == uuid),
            sensor,
          );
        }

        temperatureObs.value = sensor.temperature;
        intensityObs.value = sensor.light;
        conductivityObs.value = sensor.conductivity;
        moistureObs.value = sensor.moisture;

        yield sensor;
      } else {
        d.log('No sensor data found in the database', name: 'sensor-db');
        yield null;
      }
    } catch (e) {
      d.log('Error getting latest sensor value: $e', name: 'sensor-db');
      yield null;
    }
  }

  Sensor? fetchLatestData(String uuid) {
    return SensorDB.fetchLatestSensor(uuid);
  }
}
