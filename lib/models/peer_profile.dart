class PeerProfile {
  final String endpointId;
  final String prn;
  final String name;
  final String gender;
  final String year;
  final String branch;
  final String photoPath;
  final List<String> tags;
  final List<String> goals;
  final String prefGender;
  final String prefYear;
  final List<String> overlappingTags;

  const PeerProfile({
    required this.endpointId,
    required this.prn,
    required this.name,
    required this.gender,
    required this.year,
    required this.branch,
    this.photoPath = '',
    required this.tags,
    required this.goals,
    this.prefGender = 'Any',
    this.prefYear = 'Any',
    this.overlappingTags = const [],
  });

  factory PeerProfile.fromJson(Map<String, dynamic> json, String endpointId, List<String> overlap) {
    return PeerProfile(
      endpointId: endpointId,
      prn: json['prn'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? '',
      year: json['year'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      photoPath: json['photoPath'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      goals: List<String>.from(json['goals'] as List? ?? []),
      prefGender: json['prefGender'] as String? ?? 'Any',
      prefYear: json['prefYear'] as String? ?? 'Any',
      overlappingTags: overlap,
    );
  }

  Map<String, dynamic> toJson() => {
        'prn': prn,
        'name': name,
        'gender': gender,
        'year': year,
        'branch': branch,
        'photoPath': photoPath,
        'tags': tags,
        'goals': goals,
        'prefGender': prefGender,
        'prefYear': prefYear,
      };
}
