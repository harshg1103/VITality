import 'package:hive/hive.dart';

part 'match_model.g.dart';

@HiveType(typeId: 1)
class MatchModel extends HiveObject {
  @HiveField(0)
  late String matchId;

  @HiveField(1)
  late String peerPrn;

  @HiveField(2)
  late String peerName;

  @HiveField(3)
  String peerPhotoPath = '';

  @HiveField(4)
  List<String> peerTags = [];

  @HiveField(5)
  String peerYear = '';

  @HiveField(6)
  String peerBranch = '';

  @HiveField(7)
  List<String> messages = [];

  @HiveField(8)
  late int timestamp;

  MatchModel({
    required this.matchId,
    required this.peerPrn,
    required this.peerName,
    this.peerPhotoPath = '',
    List<String>? peerTags,
    this.peerYear = '',
    this.peerBranch = '',
    List<String>? messages,
    required this.timestamp,
  }) {
    this.peerTags = peerTags ?? [];
    this.messages = messages ?? [];
  }
}
