class AppUser {
  final int id;
  final String name;
  final String email;

  AppUser({required this.id, required this.name, required this.email});

  static AppUser fromJson(Map<String, dynamic> j) {
    int toInt(dynamic x) => x is num ? x.toInt() : int.tryParse(x.toString()) ?? 0;
    return AppUser(
      id: toInt(j['id']),
      name: (j['name'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
    );
  }
}
