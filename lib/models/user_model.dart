import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String prn;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String password;

  @HiveField(3)
  late String gender;

  @HiveField(4)
  late String year;

  @HiveField(5)
  late String branch;

  @HiveField(6)
  String bio = '';

  @HiveField(7)
  String photoPath = '';

  @HiveField(8)
  List<String> tags = [];

  @HiveField(9)
  List<String> goals = [];

  @HiveField(10)
  String prefGender = 'Any';

  @HiveField(11)
  String prefYear = 'Any';

  @HiveField(12)
  String jwtToken = '';

  UserModel({
    required this.prn,
    required this.name,
    required this.password,
    required this.gender,
    required this.year,
    required this.branch,
    this.bio = '',
    this.photoPath = '',
    List<String>? tags,
    List<String>? goals,
    this.prefGender = 'Any',
    this.prefYear = 'Any',
    this.jwtToken = '',
  }) {
    this.tags = tags ?? [];
    this.goals = goals ?? [];
  }
}
