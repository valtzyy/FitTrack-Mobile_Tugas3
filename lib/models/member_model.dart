// Model data untuk entitas anggota kelompok/pengguna pada tabel SQLite 'members'
class MemberModel {
  final int? id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final String createdAt;

  MemberModel({
    this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.createdAt,
  });

  // Mengubah Map dari baris database SQLite menjadi objek MemberModel
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String,
      age: map['age'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  // Mengubah objek MemberModel menjadi Map untuk query SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  MemberModel copyWith({
    int? id,
    String? name,
    String? email,
    String? gender,
    int? age,
    String? createdAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
