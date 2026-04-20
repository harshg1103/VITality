// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

class MatchModelAdapter extends TypeAdapter<MatchModel> {
  @override
  final int typeId = 1;

  @override
  MatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchModel(
      matchId: fields[0] as String,
      peerPrn: fields[1] as String,
      peerName: fields[2] as String,
      peerPhotoPath: fields[3] as String? ?? '',
      peerTags: (fields[4] as List?)?.cast<String>() ?? [],
      peerYear: fields[5] as String? ?? '',
      peerBranch: fields[6] as String? ?? '',
      messages: (fields[7] as List?)?.cast<String>() ?? [],
      timestamp: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MatchModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.matchId)
      ..writeByte(1)
      ..write(obj.peerPrn)
      ..writeByte(2)
      ..write(obj.peerName)
      ..writeByte(3)
      ..write(obj.peerPhotoPath)
      ..writeByte(4)
      ..write(obj.peerTags)
      ..writeByte(5)
      ..write(obj.peerYear)
      ..writeByte(6)
      ..write(obj.peerBranch)
      ..writeByte(7)
      ..write(obj.messages)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
