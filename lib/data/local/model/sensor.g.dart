// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SensorAdapter extends TypeAdapter<Sensor> {
  @override
  final int typeId = 0;

  @override
  Sensor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sensor(
      uuid: fields[0] as String?,
      light: fields[1] as int,
      temperature: fields[4] as double,
      conductivity: fields[2] as int,
      moisture: fields[3] as int,
      localName: fields[5] as String,
      bioName: fields[6] as String,
      dateTime: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sensor obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.light)
      ..writeByte(2)
      ..write(obj.conductivity)
      ..writeByte(3)
      ..write(obj.moisture)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.localName)
      ..writeByte(6)
      ..write(obj.bioName)
      ..writeByte(7)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
