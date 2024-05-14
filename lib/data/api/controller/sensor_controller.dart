import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skripsyit/data/local/model/sensor.dart';

class SensorController extends GetxController {
  DatabaseReference ref = FirebaseDatabase.instance.ref('/');

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

      log(sensor.toString(), name: 'sensor');
      return snap.value;
    }
  }
}
