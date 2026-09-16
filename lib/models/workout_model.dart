// Model data untuk entitas aktivitas latihan fisik pada tabel SQLite 'workouts'
class WorkoutModel {
  final int? id;
  final String exerciseName;
  final int durationMinutes;
  final int calories;
  final String workoutDate;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  WorkoutModel({
    this.id,
    required this.exerciseName,
    required this.durationMinutes,
    required this.calories,
    required this.workoutDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Konversi dari Map SQLite menjadi objek WorkoutModel
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as int?,
      exerciseName: map['exercise_name'] as String,
      durationMinutes: map['duration_minutes'] as int,
      calories: map['calories'] as int,
      workoutDate: map['workout_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Konversi dari objek WorkoutModel menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exercise_name': exerciseName,
      'duration_minutes': durationMinutes,
      'calories': calories,
      'workout_date': workoutDate,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  WorkoutModel copyWith({
    int? id,
    String? exerciseName,
    int? durationMinutes,
    int? calories,
    String? workoutDate,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      workoutDate: workoutDate ?? this.workoutDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
