import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../services/database_service.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
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
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => _WorkoutFormDialog(existingWorkout: existingWorkout),
    );

    if (success == true && mounted) {
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
    }
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

// Dialog formulir modal untuk Tambah atau Ubah catatan latihan secara terisolasi dan aman
class _WorkoutFormDialog extends StatefulWidget {
  final WorkoutModel? existingWorkout;
  const _WorkoutFormDialog({this.existingWorkout});

  @override
  State<_WorkoutFormDialog> createState() => _WorkoutFormDialogState();
}

class _WorkoutFormDialogState extends State<_WorkoutFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  bool get _isEdit => widget.existingWorkout != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingWorkout;
    _nameController = TextEditingController(text: existing?.exerciseName ?? '');
    _durationController = TextEditingController(
      text: existing != null ? existing.durationMinutes.toString() : '',
    );
    _caloriesController = TextEditingController(
      text: existing != null ? existing.calories.toString() : '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');

    _selectedDate = existing != null
        ? (AppFormatters.parseDate(existing.workoutDate) ?? DateTime.now())
        : DateTime.now();

    _dateController = TextEditingController(
      text: AppFormatters.formatDate(_selectedDate),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now().toIso8601String();

      if (_isEdit) {
        final updated = widget.existingWorkout!.copyWith(
          exerciseName: _nameController.text.trim(),
          durationMinutes: int.parse(_durationController.text.trim()),
          calories: int.parse(_caloriesController.text.trim()),
          workoutDate: _dateController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: now,
        );
        await DatabaseService.instance.updateWorkout(updated);
      } else {
        final created = WorkoutModel(
          exerciseName: _nameController.text.trim(),
          durationMinutes: int.parse(_durationController.text.trim()),
          calories: int.parse(_caloriesController.text.trim()),
          workoutDate: _dateController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          createdAt: now,
          updatedAt: now,
        );
        await DatabaseService.instance.insertWorkout(created);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan latihan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(width: 8),
          Text(
            _isEdit ? 'Ubah Catatan Latihan' : 'Tambah Latihan Baru',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Nama Latihan',
                hint: 'Contoh: Jogging, Push Up',
                prefixIcon: Icons.fitness_center_rounded,
                validator: (val) => AppValidators.validateRequired(val, 'Nama latihan'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _durationController,
                label: 'Durasi (Menit)',
                hint: 'Contoh: 30',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (val) => AppValidators.validatePositiveInteger(val, 'Durasi'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _caloriesController,
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
              AppTextField(
                controller: _dateController,
                label: 'Tanggal Latihan',
                readOnly: true,
                prefixIcon: Icons.calendar_today_outlined,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _selectedDate = picked;
                    setState(() {
                      _dateController.text = AppFormatters.formatDate(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _notesController,
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
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
