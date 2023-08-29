// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetupAdapter extends TypeAdapter<Setup> {
  @override
  final int typeId = 0;

  @override
  Setup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setup(
      fontSize: fields[0] as double,
      itemSize: fields[1] as double,
      useEnter: fields[2] as bool,
      isReverse: fields[3] as bool,
      isDarkTheme: fields[4] as bool,
      isListView: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Setup obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.itemSize)
      ..writeByte(2)
      ..write(obj.useEnter)
      ..writeByte(3)
      ..write(obj.isReverse)
      ..writeByte(4)
      ..write(obj.isDarkTheme)
      ..writeByte(5)
      ..write(obj.isListView);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
