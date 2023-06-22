// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyCategoryAdapter extends TypeAdapter<MyCategory> {
  @override
  final int typeId = 0;

  @override
  MyCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyCategory(
      name: fields[1] as String,
      id: fields[0] as int,
      isVisible: fields[2] as bool,
      subItems: (fields[3] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, MyCategory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isVisible)
      ..writeByte(3)
      ..write(obj.subItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
