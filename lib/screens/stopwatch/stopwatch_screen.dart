import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

// Layar Stopwatch untuk mencatat waktu latihan fisik
// Menggunakan Timer.periodic dengan penanganan siklus hidup yang aman dari kebocoran memori.
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

enum StopwatchStatus { initial, running, paused }

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? _timer;
  int _millisecondsElapsed = 0;
  StopwatchStatus _status = StopwatchStatus.initial;

  @override
  void dispose() {
    // PENTING: Membatalkan timer saat widget dihancurkan agar tidak terjadi memory leak
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  // Memulai timer stopwatch
  void _startTimer() {
    // Mencegah pembuatan timer ganda jika sudah ada timer aktif
    if (_timer != null && _timer!.isActive) return;

    setState(() {
      _status = StopwatchStatus.running;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _millisecondsElapsed += 50;
      });
    });
  }

  // Menghentikan sementara waktu (Pause)
  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _status = StopwatchStatus.paused;
      });
    }
  }

  // Melanjutkan stopwatch dari waktu terakhir (Resume)
  void _resumeTimer() {
    _startTimer();
  }

  // Mengatur ulang stopwatch kembali ke 0 (Reset)
  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _millisecondsElapsed = 0;
        _status = StopwatchStatus.initial;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatted = AppFormatters.formatStopwatch(_millisecondsElapsed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch Latihan'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lingkaran visual stopwatch
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: _status == StopwatchStatus.running
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 36,
                          color: _status == StopwatchStatus.running
                              ? theme.colorScheme.primary
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(height: 12),
                        // Teks Angka Waktu (Skala otomatis menyesuaikan saat mencapai jam HH:MM:SS)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              timeFormatted,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                color: _status == StopwatchStatus.running
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Indikator status
                        Text(
                          _status == StopwatchStatus.running
                              ? 'SEDANG BERJALAN'
                              : _status == StopwatchStatus.paused
                                  ? 'DIHENTIKAN'
                                  : 'SIAP',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                            color: _status == StopwatchStatus.running
                                ? Colors.green.shade700
                                : _status == StopwatchStatus.paused
                                    ? Colors.amber.shade800
                                    : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Tombol aksi: Start, Pause, Resume, Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Reset
                    ElevatedButton(
                      onPressed: _millisecondsElapsed > 0 ? _resetTimer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                        elevation: 0,
                      ),
                      child: const Icon(Icons.refresh, size: 28),
                    ),
                    const SizedBox(width: 24),

                    // Tombol Start / Pause / Resume
                    if (_status == StopwatchStatus.initial)
                      ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          elevation: 3,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 36),
                      )
                    else if (_status == StopwatchStatus.running)
                      ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          elevation: 3,
                        ),
                        child: const Icon(Icons.pause_rounded, size: 36),
                      )
                    else
                      ElevatedButton(
                        onPressed: _resumeTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          elevation: 3,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 36),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _status == StopwatchStatus.running
                      ? 'Ketuk jeda untuk menghentikan sementara'
                      : _status == StopwatchStatus.paused
                          ? 'Ketuk putar untuk melanjutkan kembali'
                          : 'Ketuk tombol hijau untuk mulai menghitung',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
