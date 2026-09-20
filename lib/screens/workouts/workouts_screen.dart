import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../services/database_service.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';

// Layar Menu CRUD Tema: Manajemen Catatan Latihan Fisik (Workouts)
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  List<WorkoutModel> _workouts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  // Mengambil seluruh data catatan latihan dari SQLite
  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _dbService.getAllWorkouts();
      if (!mounted) return;
      setState(() {
        _workouts = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data latihan. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  // Menampilkan modal dialog untuk Tambah (Create) atau Ubah (Update) Latihan
  Future<void> _showWorkoutFormDialog({WorkoutModel? existingWorkout}) async {
    final isEdit = existingWorkout != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingWorkout?.exerciseName ?? '');
    final durationController = TextEditingController(
      text: existingWorkout != null ? existingWorkout.durationMinutes.toString() : '',
    );
    final caloriesController = TextEditingController(
      text: existingWorkout != null ? existingWorkout.calories.toString() : '',
    );
    final notesController = TextEditingController(text: existingWorkout?.notes ?? '');

    // Default tanggal hari ini atau tanggal latihan yang sedang diedit
    DateTime selectedDate = existingWorkout != null
        ? (AppFormatters.parseDate(existingWorkout.workoutDate) ?? DateTime.now())
        : DateTime.now();

    final dateController = TextEditingController(
      text: AppFormatters.formatDate(selectedDate),
    );

    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (modalCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Ubah Catatan Latihan' : 'Tambah Latihan Baru',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nama Latihan
                  AppTextField(
                    controller: nameController,
                    label: 'Nama Latihan',
                    hint: 'Contoh: Jogging, Push Up',
                    prefixIcon: Icons.fitness_center_rounded,
                    validator: (val) => AppValidators.validateRequired(val, 'Nama latihan'),
                  ),
                  const SizedBox(height: 12),

                  // Durasi (menit)
                  AppTextField(
                    controller: durationController,
                    label: 'Durasi (Menit)',
                    hint: 'Contoh: 30',
                    prefixIcon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) => AppValidators.validatePositiveInteger(val, 'Durasi'),
                  ),
                  const SizedBox(height: 12),

                  // Kalori terbakar
                  AppTextField(
                    controller: caloriesController,
                    label: 'Kalori Terbakar (kkal)',
                    hint: 'Contoh: 200',
                    prefixIcon: Icons.local_fire_department_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) => AppValidators.validatePositiveInteger(
                      val,
                      'Kalori',
                      allowZero: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tanggal Latihan (DatePicker)
                  AppTextField(
                    controller: dateController,
                    label: 'Tanggal Latihan',
                    readOnly: true,
                    prefixIcon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                        setDialogState(() {
                          dateController.text = AppFormatters.formatDate(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Catatan tambahan (opsional)
                  AppTextField(
                    controller: notesController,
                    label: 'Catatan (Opsional)',
                    hint: 'Contoh: Pagi hari sebelum kuliah',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            SizedBox(
              width: 140,
              child: AppButton(
                text: isEdit ? 'Simpan' : 'Tambah',
                height: 40,
                isLoading: isSubmitting,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  setDialogState(() => isSubmitting = true);

                  try {
                    final now = DateTime.now().toIso8601String();

                    if (isEdit) {
                      // UPDATE latihan
                      final updated = existingWorkout.copyWith(
                        exerciseName: nameController.text.trim(),
                        durationMinutes: int.parse(durationController.text.trim()),
                        calories: int.parse(caloriesController.text.trim()),
                        workoutDate: dateController.text.trim(),
                        notes: notesController.text.trim().isNotEmpty
                            ? notesController.text.trim()
                            : null,
                        updatedAt: now,
                      );
                      await _dbService.updateWorkout(updated);
                    } else {
                      // CREATE latihan
                      final created = WorkoutModel(
                        exerciseName: nameController.text.trim(),
                        durationMinutes: int.parse(durationController.text.trim()),
                        calories: int.parse(caloriesController.text.trim()),
                        workoutDate: dateController.text.trim(),
                        notes: notesController.text.trim().isNotEmpty
                            ? notesController.text.trim()
                            : null,
                        createdAt: now,
                        updatedAt: now,
                      );
                      await _dbService.insertWorkout(created);
                    }

                    if (!modalCtx.mounted) return;
                    Navigator.pop(dialogCtx);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Data latihan berhasil diperbarui.'
                              : 'Data latihan berhasil disimpan.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    _fetchWorkouts();
                  } catch (e) {
                    if (modalCtx.mounted) {
                      setDialogState(() => isSubmitting = false);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan latihan: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    dateController.dispose();
    notesController.dispose();
  }

  // Menghapus data latihan dengan dialog konfirmasi wajib
  Future<void> _deleteWorkout(WorkoutModel workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus latihan ini?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${workout.exerciseName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && workout.id != null) {
      try {
        await _dbService.deleteWorkout(workout.id!);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data latihan berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );

        _fetchWorkouts();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data gagal dihapus. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Latihan Fisik'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkoutFormDialog(),
        tooltip: 'Tambah Latihan',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State
    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _fetchWorkouts,
      );
    }

    // 3. Empty State
    if (_workouts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.fitness_center_rounded,
        title: 'Belum ada aktivitas latihan.',
        message: 'Mulai catat latihan pertama Anda untuk menjaga kebugaran tubuh.',
        actionButtonText: 'Tambah Latihan',
        onActionPressed: () => _showWorkoutFormDialog(),
      );
    }

    // 4. Success State (READ ListView)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _workouts.length,
      itemBuilder: (context, index) {
        final workout = _workouts[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFFF97316),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.exerciseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                workout.workoutDate,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tombol Edit (UPDATE)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      tooltip: 'Ubah Latihan',
                      onPressed: () => _showWorkoutFormDialog(existingWorkout: workout),
                    ),
                    // Tombol Hapus (DELETE)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                      tooltip: 'Hapus Latihan',
                      onPressed: () => _deleteWorkout(workout),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Badge Durasi dan Kalori
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.blue.shade800),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.durationMinutes} Menit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department_outlined, size: 14, color: Colors.orange.shade800),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.calories} kkal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Catatan: ${workout.notes}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
