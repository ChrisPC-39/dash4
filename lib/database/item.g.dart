// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 1;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      name: fields[1] as String,
      id: fields[0] as int,
      isSection: fields[2] as bool,
      isSelected: fields[3] as bool,
      isEditing: fields[4] as bool,
      isVisible: fields[5] as bool,
      details: fields[7] as String,
      images: (fields[6] as List?)?.cast<Uint8List>(),
      tagPointer: (fields[8] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isSection)
      ..writeByte(3)
      ..write(obj.isSelected)
      ..writeByte(4)
      ..write(obj.isEditing)
      ..writeByte(5)
      ..write(obj.isVisible)
      ..writeByte(6)
      ..write(obj.images)
      ..writeByte(7)
      ..write(obj.details)
      ..writeByte(8)
      ..write(obj.tagPointer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
