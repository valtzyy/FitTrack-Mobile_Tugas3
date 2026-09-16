// Model data untuk entitas pengguna (User) pada tabel SQLite 'users'
class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final String name;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.name,
    required this.createdAt,
  });

  // Mengubah Map dari baris SQLite menjadi objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  // Mengubah objek UserModel menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'password_hash': passwordHash,
      'name': name,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? name,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
