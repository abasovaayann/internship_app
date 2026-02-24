class AppUser {
  final int id;
  final String name;
  final String email;
  final String university;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.university,
  });

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? university,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      university: university ?? this.university,
    );
  }
}
