import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

// Layanan tunggal (Singleton) untuk mengelola basis data SQLite lokal aplikasi FitTrack.
// Menangani inisialisasi basis data, pembuatan tabel, seeder data demo, dan operasi CRUD.
class DatabaseService {
  // Pola Singleton agar hanya ada satu koneksi database yang dibuka
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // Getter database: membuka database jika belum diinisialisasi
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fittrack.db');
    return _database!;
  }

  // Fungsi helper untuk melakukan hash SHA-256 pada kata sandi
  // CATATAN EDUKASI:
  // SHA-256 digunakan untuk kebutuhan pembelajaran/demo tugas kuliah dan bukan
  // merupakan mekanisme penyimpanan password production-grade (seperti Argon2/Bcrypt).
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Membuka database SQLite di path penyimpanan perangkat
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Membuat tabel-tabel SQLite saat basis data pertama kali dibuat
  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Tabel members
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        gender TEXT NOT NULL,
        age INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Tabel workouts
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        workout_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Mengisi data awal (seed) agar aplikasi siap dipresentasikan langsung
    await _seedInitialData(db);
  }

  // Fungsi seeder untuk memasukkan akun demo dan data contoh awal
  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 1. Seed akun demo bawaan (admin / admin123)
    final adminUser = UserModel(
      username: AppConstants.defaultUsername,
      passwordHash: hashPassword(AppConstants.defaultPassword),
      name: AppConstants.defaultFullName,
      createdAt: now,
    );
    await db.insert('users', adminUser.toMap());

    // 2. Seed data anggota tim / mahasiswa contoh
    final initialMembers = [
      MemberModel(
        name: 'Ahmad Faiz',
        email: 'faiz@student.ac.id',
        gender: 'Laki-laki',
        age: 21,
        createdAt: now,
      ),
      MemberModel(
        name: 'Siti Nurhaliza',
        email: 'siti@student.ac.id',
        gender: 'Perempuan',
        age: 20,
        createdAt: now,
      ),
      MemberModel(
        name: 'Budi Santoso',
        email: 'budi@student.ac.id',
        gender: 'Laki-laki',
        age: 22,
        createdAt: now,
      ),
    ];

    for (final member in initialMembers) {
      await db.insert('members', member.toMap());
    }

    // 3. Seed data latihan fisik contoh
    final initialWorkouts = [
      WorkoutModel(
        exerciseName: 'Jogging Pagi',
        durationMinutes: 30,
        calories: 220,
        workoutDate: '16/09/2026',
        notes: 'Keliling lapangan kampus 5 putaran.',
        createdAt: now,
        updatedAt: now,
      ),
      WorkoutModel(
        exerciseName: 'Push Up & Sit Up',
        durationMinutes: 20,
        calories: 120,
        workoutDate: '15/09/2026',
        notes: 'Latihan kalistenik dasar di kamar asrama.',
        createdAt: now,
        updatedAt: now,
      ),
      WorkoutModel(
        exerciseName: 'Bersepeda Santai',
        durationMinutes: 45,
        calories: 300,
        workoutDate: '14/09/2026',
        notes: 'Gowes sore bersama teman kuliah.',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final workout in initialWorkouts) {
      await db.insert('workouts', workout.toMap());
    }
  }

  // ===========================================================================
  // OPERASI TABEL USERS
  // ===========================================================================

  // Mengambil data pengguna berdasarkan username (parameterized query)
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username.trim().toLowerCase()],
      );

      if (results.isNotEmpty) {
        return UserModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal membaca data pengguna dari basis data: $e');
    }
  }

  // Menambahkan pengguna baru
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap());
    } catch (e) {
      throw Exception('Gagal mendaftarkan pengguna baru: $e');
    }
  }

  // ===========================================================================
  // OPERASI TABEL MEMBERS (Daftar Anggota)
  // ===========================================================================

  // Mengambil seluruh data anggota terurut dari yang terbaru
  Future<List<MemberModel>> getAllMembers() async {
    try {
      final db = await database;
      final results = await db.query(
        'members',
        orderBy: 'id DESC',
      );
      return results.map((map) => MemberModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar anggota: $e');
    }
  }

  // Menambahkan data anggota baru
  Future<int> insertMember(MemberModel member) async {
    try {
      final db = await database;
      return await db.insert('members', member.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan data anggota baru: $e');
    }
  }

  // Menghapus data anggota berdasarkan ID
  Future<int> deleteMember(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'members',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data anggota: $e');
    }
  }

  // ===========================================================================
  // OPERASI TABEL WORKOUTS (CRUD Latihan Fisik)
  // ===========================================================================

  // READ: Mengambil seluruh riwayat latihan terurut dari yang terbaru
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final db = await database;
      final results = await db.query(
        'workouts',
        orderBy: 'id DESC',
      );
      return results.map((map) => WorkoutModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal memuat riwayat latihan fisik: $e');
    }
  }

  // CREATE: Menyimpan data latihan baru ke SQLite
  Future<int> insertWorkout(WorkoutModel workout) async {
    try {
      final db = await database;
      return await db.insert('workouts', workout.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan data latihan fisik: $e');
    }
  }

  // UPDATE: Memperbarui data latihan yang sudah ada berdasarkan ID
  Future<int> updateWorkout(WorkoutModel workout) async {
    if (workout.id == null) {
      throw ArgumentError('ID latihan tidak boleh bernilai null saat memperbarui.');
    }
    try {
      final db = await database;
      return await db.update(
        'workouts',
        workout.toMap(),
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui data latihan fisik: $e');
    }
  }

  // DELETE: Menghapus data latihan berdasarkan ID
  Future<int> deleteWorkout(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data latihan fisik: $e');
    }
  }

  // Menutup koneksi basis data SQLite dengan aman
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
