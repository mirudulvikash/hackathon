import 'dart:convert';

class UserProfile {
  final String name;
  final String role;
  final String institution;
  final String location;
  final List<String> preferredCategories;

  UserProfile({
    required this.name,
    required this.role,
    required this.institution,
    required this.location,
    required this.preferredCategories,
  });

  UserProfile copyWith({
    String? name,
    String? role,
    String? institution,
    String? location,
    List<String>? preferredCategories,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      institution: institution ?? this.institution,
      location: location ?? this.location,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }

  // To check if profile setup is done
  bool get isComplete =>
      name.isNotEmpty &&
      role.isNotEmpty &&
      institution.isNotEmpty &&
      location.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'institution': institution,
      'location': location,
      'preferredCategories': preferredCategories,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      institution: map['institution'] ?? '',
      location: map['location'] ?? '',
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
