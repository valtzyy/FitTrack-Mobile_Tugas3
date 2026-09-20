import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/database_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';

// Layar Daftar Anggota untuk melihat dan mengelola data anggota/mahasiswa kelompok
class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  List<MemberModel> _members = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // Mengambil daftar anggota dari basis data SQLite
  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _dbService.getAllMembers();
      if (!mounted) return;
      setState(() {
        _members = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat daftar anggota. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  // Menampilkan dialog formulir untuk menambah data anggota baru
  Future<void> _showAddMemberDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _AddMemberDialog(),
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anggota baru berhasil ditambahkan.'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchMembers();
    }
  }

  // Menghapus data anggota dengan konfirmasi dialog
  Future<void> _deleteMember(MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggota?'),
        content: Text('Yakin ingin menghapus data "${member.name}" dari daftar anggota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && member.id != null) {
      try {
        await _dbService.deleteMember(member.id!);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data anggota berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );

        _fetchMembers();
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
        title: const Text('Daftar Anggota'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        tooltip: 'Tambah Anggota',
        child: const Icon(Icons.person_add_rounded),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Error State
    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _fetchMembers,
      );
    }

    // 3. Empty State
    if (_members.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.group_off_rounded,
        title: 'Belum ada data anggota.',
        message: 'Tekan tombol tambah di bawah untuk menambahkan anggota pertama.',
        actionButtonText: 'Tambah Anggota',
        onActionPressed: _showAddMemberDialog,
      );
    }

    // 4. Success State
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final isMale = member.gender == 'Laki-laki';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Avatar Jenis Kelamin
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isMale
                      ? Colors.blue.shade100
                      : Colors.pink.shade100,
                  child: Icon(
                    isMale ? Icons.face_rounded : Icons.face_3_rounded,
                    color: isMale ? Colors.blue.shade800 : Colors.pink.shade800,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                // Informasi Nama, Email, dan Usia
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              member.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Badge Jenis Kelamin dan Usia
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMale ? Colors.blue.shade50 : Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.gender,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMale ? Colors.blue.shade800 : Colors.pink.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${member.age} Tahun',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tombol Hapus Anggota
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                  tooltip: 'Hapus Anggota',
                  onPressed: () => _deleteMember(member),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dialog formulir modal untuk menambah data anggota baru secara terisolasi dan aman
class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog();

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;
  String _selectedGender = 'Laki-laki';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final newMember = MemberModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text.trim()),
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseService.instance.insertMember(newMember);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0F766E)),
          SizedBox(width: 8),
          Text('Tambah Anggota', style: TextStyle(fontSize: 18)),
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
                label: 'Nama Lengkap',
                hint: 'Contoh: Ahmad Faiz',
                prefixIcon: Icons.badge_outlined,
                validator: (val) => AppValidators.validateRequired(val, 'Nama lengkap'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _emailController,
                label: 'Alamat Email',
                hint: 'Contoh: faiz@student.ac.id',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _ageController,
                label: 'Usia (Tahun)',
                hint: 'Contoh: 21',
                prefixIcon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (val) => AppValidators.validatePositiveInteger(val, 'Usia'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  prefixIcon: const Icon(Icons.transgender_outlined, size: 22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedGender = val);
                  }
                },
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
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
