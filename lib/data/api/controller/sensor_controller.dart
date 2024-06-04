import 'dart:convert';
import 'dart:developer' as d;
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:skripsyit/data/local/db/sensor_db.dart';
import 'package:skripsyit/data/local/fuzzy_logic.dart';
import 'package:skripsyit/data/local/model/sensor.dart';
import 'package:skripsyit/utils/shared_prefs.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SensorController extends GetxController {
  late Box<Sensor> _sensorBox;
  late Interpreter? _interpreter;

  final SharedPreferenceService _sharedPrefs = SharedPreferenceService();
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

    await loadModel();
    await predictLatestData();

    super.onInit();
  }

  Future<void> loadModel() async {
    try {
      // Load the TensorFlow Lite model
      final modelData = await rootBundle.load('assets/rf_tf_model.tflite');
      _interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List());

      d.log('Model loaded successfully', name: 'tf-lite-model');
    } catch (e) {
      d.log('Error loading model: $e', name: 'tf-lite-model');
    }
  }

  Future<void> predictLatestData() async {
    try {
      final snap = await ref.child('sensor').limitToLast(1).get();

      if (snap.exists) {
        var data = snap.children.last.value;
        Map<String, dynamic> dataDecode = json.decode(jsonEncode(data));

        Sensor latestSensor = Sensor(
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

        sensorObs.value = latestSensor;

        if (sensorObs.value != null) {
          SensorDB.insertSensor(latestSensor);

          final List<double> inputData = [
            latestSensor.temperature.toDouble(),
            latestSensor.light.toDouble(),
            latestSensor.conductivity.toDouble(),
            latestSensor.moisture.toDouble(),
          ];

          await runInference(inputData);
        } else {
          d.log(
            'No latest sensor data available for prediction',
            name: 'predict-model',
          );
        }
      } else {
        d.log(
          'No latest sensor data available for prediction - 2',
          name: 'predict-model',
        );
      }
    } catch (e) {
      d.log(
        'Error predicting latest data: $e',
        name: 'predict-model',
      );
    }
  }

  Future<void> runInference(List<double> inputData) async {
    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      // Check input tensor shape
      if (inputTensor.shape.length != 2 ||
          inputTensor.shape[1] != inputData.length) {
        d.log('Input tensor shape does not match input data', name: 'tf-model');
        return;
      }

      // Log output tensor shape and data type
      d.log('Output tensor shape: ${outputTensor.shape}', name: 'tf-model');
      d.log('Output tensor type: ${outputTensor.type}', name: 'tf-model');

      // Create input and output buffers
      final inputBuffer =
          Float32List(inputTensor.shape.reduce((a, b) => a * b));
      final outputBuffer =
          Float32List(outputTensor.shape.reduce((a, b) => a * b));

      // Copy input data to input buffer
      for (int i = 0; i < inputData.length; i++) {
        inputBuffer[i] = inputData[i];
      }

      // Run inference
      _interpreter!.run(inputBuffer.buffer, outputBuffer.buffer);

      // Extract output data
      final outputData = outputBuffer;

      // Perform any necessary post-processing on outputData
      // For example, finding the index with maximum value
      final predictionIndex =
          outputData.indexOf(outputData.reduce((a, b) => a > b ? a : b));

      // Set conditionObs value based on prediction
      conditionObs.value = predictionIndex == 0
          ? 'Optimal'
          : (predictionIndex == 1 ? 'Caution' : 'Extreme');

      d.log('Inputs: $inputData', name: 'tf-model');
      d.log('Prediction: ${conditionObs.value}', name: 'tf-model');
    } catch (e) {
      d.log('Failed to run inference: $e', name: 'tf-model');
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
