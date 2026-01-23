class Cinema {
  final int id;
  final String name;
  final String? location;

  Cinema({required this.id, required this.name, this.location});

  static Cinema fromJson(Map<String, dynamic> j) {
    int toInt(dynamic x) => x is num ? x.toInt() : int.tryParse(x.toString()) ?? 0;
    return Cinema(
      id: toInt(j['id']),
      name: (j['name'] ?? j['title'] ?? '').toString(),
      location: (j['location'] ?? j['address'])?.toString(),
    );
  }
}
