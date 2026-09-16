# FitTrack
**"Aplikasi Manajemen Kebugaran & Kesehatan Pribadi Sederhana"**

FitTrack adalah aplikasi mobile berbasis **Flutter** yang dibangun untuk memenuhi tugas besar mata kuliah **Pemrograman Aplikasi Mobile (Semester 5)**. Aplikasi ini dirancang dengan pendekatan arsitektur yang bersih (*clean*), terstruktur, stabil, dan ramah bagi mahasiswa pemula (*beginner-friendly*), sehingga sangat mudah dipahami, dijelaskan, dan dipresentasikan di hadapan dosen penguji.

---

## 📋 Daftar Isi
1. [Deskripsi Proyek](#-deskripsi-proyek)
2. [Fitur-Fitur Utama](#-fitur-fitur-utama)
3. [Teknologi & Dependensi](#-teknologi--dependensi)
4. [Arsitektur Aplikasi](#-arsitektur-aplikasi)
5. [Struktur Folder](#-struktur-folder)
6. [Struktur Basis Data (SQLite)](#-struktur-basis-data-sqlite)
7. [Alur Otentikasi & Sesi](#-alur-otentikasi--sesi)
8. [Alur CRUD Latihan Fisik](#-alur-crud-latihan-fisik)
9. [Penjelasan Perhitungan Inti](#-penjelasan-perhitungan-inti)
10. [Akun Demo Bawaan](#-akun-demo-bawaan)
11. [Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
12. [Cara Mereset Basis Data](#-cara-mereset-basis-data)
13. [Petunjuk Pengujian (Testing)](#-petunjuk-pengujian-testing)
14. [Batasan Aplikasi (Known Limitations)](#-batasan-aplikasi-known-limitations)
15. [Pembagian Tugas Kelompok (3-4 Mahasiswa)](#-pembagian-tugas-kelompok-3-4-mahasiswa)

---

## 🏃 Deskripsi Proyek
FitTrack membantu pengguna sehari-hari (termasuk mahasiswa) untuk memantau kesehatan pribadi secara mandiri:
- Mencatat dan mengelola aktivitas olahraga (*workout*).
- Menghitung Indeks Massa Tubuh (BMI) dengan kategori edukatif.
- Melakukan konversi satuan berat badan / beban latihan.
- Menghitung umur kalender secara presisi.
- Mengonversi tanggal ke Pasaran Weton Jawa dan Kalender Tradisional Saka Bali / Pawukon.
- Menyediakan stopwatch untuk menghitung durasi latihan.

> [!NOTE]
> **Pernyataan Edukasi**: FitTrack ditujukan untuk pembelajaran dan pencatatan mandiri, bukan merupakan alat diagnosis atau rekomendasi medis profesional.

---

## 🌟 Fitur-Fitur Utama

### 1. Otentikasi & Manajemen Sesi
- Login dengan validasi username & kata sandi (tidak boleh kosong).
- Akun demo bawaan yang siap digunakan (`admin` / `admin123`) dengan fitur *Auto-Fill* sekali klik.
- Penyimpanan sesi lokal menggunakan `SharedPreferences` sehingga pengguna tetap masuk setelah aplikasi ditutup.
- Dialog konfirmasi saat Logout dan pembersihan tumpukan rute navigasi.

### 2. Navigasi Bawah (Bottom Navigation Bar)
- **Beranda**: Menampilkan sapaan nama pengguna dan 6 kartu menu fungsional vertikal.
- **Stopwatch**: Penghitung waktu dengan status visual (Start, Pause, Resume, Reset) yang aman dari kebocoran memori.
- **Bantuan / Tutorial**: Berisi 10 petunjuk lengkap penggunaan aplikasi serta tombol Logout.

### 3. Enam Menu Utama Beranda
1. **Daftar Anggota**: Menampilkan daftar anggota/mahasiswa dengan nama, email, gender, dan usia (terhubung ke SQLite).
2. **Kalkulator BMI**: Perhitungan Indeks Massa Tubuh dengan batas kategori edukasi dan banner disclaimer medis.
3. **Catatan Latihan Fisik (CRUD)**: Tambah, lihat, ubah, dan hapus latihan fisik (durasi, kalori, tanggal, catatan) dengan dialog konfirmasi & SnackBar.
4. **Konversi Satuan Berat**: Konversi dua arah antara Kilogram (kg), Gram (g), Pound (lbs), dan Ounce (oz).
5. **Kalkulator Umur**: Pemilihan tanggal lahir via kalender (*DatePicker*) dengan kalkulasi presisi Tahun, Bulan, Hari, serta total estimasi hari/jam/menit/detik.
6. **Weton → Kalender Saka Bali**: Konversi tanggal Masehi ke Hari Jawa, Pasaran (Legi, Pahing, Pon, Wage, Kliwon), Bobot Neptu, serta Kalender Saka Bali (Sapta Wara, Panca Wara, Wuku Pawukon 210 hari, dan Tahun Saka).

---

## 🛠 Teknologi & Dependensi
- **Framework**: Flutter 3.47 (Channel Stable)
- **Bahasa**: Dart 3.13 (Null Safety)
- **Desain UI**: Material Design 3 (M3)
- **Basis Data**: SQLite via paket `sqflite: ^2.4.1` & `path: ^1.9.1`
- **Sesi Lokal**: `shared_preferences: ^2.5.2`
- **Format Tanggal**: `intl: ^0.20.2`
- **Keamanan Edukasi**: `crypto: ^3.0.6` (Hashing SHA-256 untuk pembelajaran)

---

## 🏛 Arsitektur Aplikasi
Aplikasi menggunakan arsitektur sederhana berbasis **Layanan Langsung (Screen $\rightarrow$ Service $\rightarrow$ SQLite)** tanpa lapisan repository yang berlebihan:

```
[ Antarmuka Pengguna (Screen / Widget) ]
                  │
                  ▼
         [ Lapisan Service ]
  ├── AuthService (Validasi & hash)
  ├── SessionService (SharedPreferences)
  └── DatabaseService (SQLite Singleton)
                  │
                  ▼
         [ Basis Data Lokal ]
         (fittrack.db - SQLite)
```

---

## 📁 Struktur Folder

```
lib/
├── main.dart                          # Titik masuk aplikasi & inisialisasi basis data
├── app/
│   ├── app.dart                       # Konfigurasi MaterialApp, tema, dan rute navigasi
│   ├── routes.dart                    # Daftar konstanta nama rute navigasi
│   └── theme.dart                     # Konfigurasi tema warna & komponen Material 3
├── models/
│   ├── user_model.dart                # Model entitas pengguna (tabel users)
│   ├── member_model.dart              # Model entitas anggota (tabel members)
│   └── workout_model.dart             # Model entitas catatan latihan (tabel workouts)
├── services/
│   ├── database_service.dart          # Singleton SQLite: DDL tabel, seeder, query CRUD
│   ├── auth_service.dart              # Logika login & pencocokan hash sandi
│   └── session_service.dart           # Pengelolaan sesi aktif pada SharedPreferences
├── screens/
│   ├── splash/splash_screen.dart      # Layar pembuka & pengecekan sesi login
│   ├── auth/login_screen.dart         # Layar login & tombol isi akun demo
│   ├── main_navigation_screen.dart    # Wadah BottomNavigationBar (Home, Stopwatch, Help)
│   ├── home/home_screen.dart          # Beranda: salam personal & 6 kartu menu vertikal
│   ├── members/members_screen.dart    # Menu 1: Daftar Anggota kelompok / pengguna
│   ├── bmi/bmi_screen.dart            # Menu 2: Kalkulator BMI & disclaimer
│   ├── workouts/workouts_screen.dart  # Menu 3: CRUD Catatan Latihan Fisik
│   ├── converter/weight_converter_screen.dart # Menu 4: Konversi Satuan Berat
│   ├── age/age_calculator_screen.dart # Menu 5: Kalkulator Umur Sadar Kalender
│   ├── calendar/weton_saka_screen.dart # Menu 6: Weton Jawa ke Saka Bali
│   ├── stopwatch/stopwatch_screen.dart # Tab Navigasi 2: Stopwatch latihan
│   └── help/help_screen.dart          # Tab Navigasi 3: Tutorial & tombol Logout
├── widgets/
│   ├── app_button.dart                # Tombol serbaguna dengan loading indicator
│   ├── app_text_field.dart            # Input teks seragam dengan validasi
│   ├── empty_state_widget.dart        # Tampilan ramah saat daftar kosong
│   └── error_state_widget.dart        # Tampilan saat terjadi kendala koneksi/query
├── utils/
│   ├── calculations.dart              # Logika murni: BMI, berat, umur, Weton, Saka Bali
│   ├── formatters.dart                # Format tanggal Indonesia (DD/MM/YYYY) & angka
│   └── validators.dart                # Validasi input formulir
└── constants/
    └── app_constants.dart             # Konstanta teks, akun demo, dan daftar rujukan
```

---

## 🗄 Struktur Basis Data (SQLite)

File database tersimpan di perangkat lokal dengan nama `fittrack.db`.

### 1. Tabel `users`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | ID Unik pengguna |
| `username` | TEXT UNIQUE NOT NULL | Username login |
| `password_hash` | TEXT NOT NULL | Hash SHA-256 kata sandi |
| `name` | TEXT NOT NULL | Nama lengkap pengguna |
| `created_at` | TEXT NOT NULL | Waktu pembuatan akun (ISO8601) |

### 2. Tabel `members`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | ID Unik anggota |
| `name` | TEXT NOT NULL | Nama lengkap anggota |
| `email` | TEXT NOT NULL | Alamat email anggota |
| `gender` | TEXT NOT NULL | Jenis kelamin ('Laki-laki' / 'Perempuan') |
| `age` | INTEGER NOT NULL | Usia dalam tahun |
| `created_at` | TEXT NOT NULL | Waktu penambahan anggota |

### 3. Tabel `workouts`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | ID Unik latihan |
| `exercise_name` | TEXT NOT NULL | Nama aktivitas (contoh: Jogging) |
| `duration_minutes` | INTEGER NOT NULL | Durasi olahraga dalam menit |
| `calories` | INTEGER NOT NULL | Estimasi kalori terbakar (kkal) |
| `workout_date` | TEXT NOT NULL | Tanggal latihan (DD/MM/YYYY) |
| `notes` | TEXT | Catatan tambahan aktivitas |
| `created_at` | TEXT NOT NULL | Waktu pembuatan data |
| `updated_at` | TEXT NOT NULL | Waktu perubahan data terakhir |

---

## 🔐 Alur Otentikasi & Sesi

1. **Aplikasi Dibuka**:
   - `SplashScreen` memeriksa status `SessionService.isLoggedIn()`.
   - Jika `true`, langsung diarahkan ke `MainNavigationScreen` (`/main`).
   - Jika `false`, diarahkan ke `LoginScreen` (`/login`).
2. **Proses Login**:
   - Pengguna memasukkan username dan password.
   - `AuthService` mencari username pada tabel `users`.
   - Kata sandi di-hash menggunakan SHA-256 dan dicocokkan dengan `password_hash` di database.
   - Jika cocok, sesi disimpan di `SharedPreferences` dan pengguna masuk ke Beranda.
3. **Proses Logout**:
   - Tombol logout di halaman Bantuan memunculkan kotak dialog konfirmasi.
   - Jika pengguna setuju, sesi SharedPreferences dibersihkan dan seluruh riwayat navigasi dihapus (`Navigator.pushNamedAndRemoveUntil`).

---

## 📝 Alur CRUD Latihan Fisik
- **Create**: Tekan tombol `+ Tambah Latihan` $\rightarrow$ Isi form dialog $\rightarrow$ `DatabaseService.insertWorkout()` $\rightarrow$ SnackBar sukses $\rightarrow$ Daftar dimuat ulang.
- **Read**: `DatabaseService.getAllWorkouts()` menampilkan riwayat dalam bentuk kartu informatif (nama latihan, tanggal, durasi, kalori, catatan).
- **Update**: Tekan ikon pensil $\rightarrow$ Form terisi data lama $\rightarrow$ Ubah data $\rightarrow$ `DatabaseService.updateWorkout()` $\rightarrow$ SnackBar sukses.
- **Delete**: Tekan ikon tempat sampah $\rightarrow$ Muncul dialog "Hapus latihan ini?" $\rightarrow$ Konfirmasi $\rightarrow$ `DatabaseService.deleteWorkout()` $\rightarrow$ SnackBar sukses.

---

## 📐 Penjelasan Perhitungan Inti

### 1. Indeks Massa Tubuh (BMI)
$$\text{BMI} = \frac{\text{Berat Badan (kg)}}{(\text{Tinggi Badan (m)})^2}$$
- **< 18.5**: Berat Badan Kurang
- **18.5 – 24.9**: Berat Badan Normal / Ideal
- **25.0 – 29.9**: Kelebihan Berat Badan
- **$\ge$ 30.0**: Obesitas

### 2. Kalkulator Umur Sadar Kalender (*Calendar-aware*)
Bukan sekadar pembagian `inDays / 365`. Algoritma membandingkan hari, bulan, dan tahun target dengan tanggal lahir. Jika hari bernilai negatif, sistem meminjam jumlah hari dari bulan sebelumnya secara akurat.

### 3. Weton Jawa & Kalender Saka Bali
- **Pasaran Jawa (5 Hari)**: Dihitung secara matematis dari selisih hari terhadap tanggal acuan terverifikasi 1 Januari 1970 (Kamis Wage). Siklus 5 hari: Legi (0), Pahing (1), Pon (2), Wage (3), Kliwon (4).
- **Bobot Neptu**: Menggunakan nilai neptu tradisional (Minggu: 5, Senin: 4, Selasa: 3, Rabu: 7, Kamis: 8, Jumat: 6, Sabtu: 9; Legi: 5, Pahing: 9, Pon: 7, Wage: 4, Kliwon: 8).
- **Pawukon Bali (210 Hari)**: Menggunakan acuan baku Hari Raya Galungan 28 Februari 2024 (Buda Kliwon Dungulan, hari ke-73 siklus Pawukon) untuk memetakan 30 Wuku (Sinta s/d Watugunung).

---

## 👤 Akun Demo Bawaan
Untuk kemudahan pengujian dan demonstrasi di depan dosen:
- **Username**: `admin`
- **Kata Sandi**: `admin123`
- *Tips*: Pada layar login, terdapat tombol **"Isi Otomatis"** yang akan langsung mengisi form login dalam 1 kali ketukan.

---

## 🚀 Cara Menjalankan Aplikasi

1. Pastikan Flutter SDK sudah terpasang di komputer:
   ```bash
   flutter doctor
   ```
2. Unduh semua paket dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada emulator atau perangkat fisik Android / Chrome:
   ```bash
   flutter run
   ```

---

## 🔄 Cara Mereset Basis Data
Jika ingin mengembalikan database ke kondisi awal (termasuk data seed default):
- **Cara 1 (Mudah)**: Masuk ke pengaturan aplikasi di perangkat / emulator Android $\rightarrow$ *App Info FitTrack* $\rightarrow$ *Storage* $\rightarrow$ *Clear Data / Clear Storage*.
- **Cara 2**: Hapus aplikasi (*Uninstall*) dan pasang kembali (*Re-install*).

---

## 🧪 Petunjuk Pengujian (Testing)

### 1. Pengujian Analisis Kode (Linter)
Pastikan kode bebas dari error analisis dan peringatan:
```bash
flutter analyze
```
*(Hasil saat ini: `No issues found!`)*

### 2. Pengujian Unit Otomatis
Jalankan 20 unit test logika murni (BMI, konversi berat, kalkulator umur, weton/pawukon, validasi form):
```bash
flutter test
```
*(Hasil saat ini: `All tests passed!`)*

---

## ⚠️ Batasan Aplikasi (Known Limitations)
1. **Penyimpanan Password**: Hashing SHA-256 digunakan untuk kebutuhan demonstrasi tugas kuliah agar mahasiswa memahami konsep dasar *one-way hashing*, bukan untuk sistem produksi berskala enterprise.
2. **Lunisolar Sasih Bali**: Kalender Saka Bali pada aplikasi ini mengonversi siklus matematis tetap Pawukon 210 hari (Wuku, Sapta Wara, Panca Wara) secara presisi. Penentuan awal Sasih bulan baru (*Tilem*) dan penyesuaian *Ngunalatri* / *Nampih Sasih* memerlukan pengamatan astronomis hilal tahunan dari para *Wariga* di Bali.

---

## 👥 Pembagian Tugas Kelompok (3-4 Mahasiswa)

| Anggota | Peran & Modul | Deskripsi Pekerjaan |
|---|---|---|
| **Mahasiswa 1** | *Authentication & Session Lead* | Mengembangkan `LoginScreen`, `SplashScreen`, `AuthService`, `SessionService`, serta navigasi rute terpusat. |
| **Mahasiswa 2** | *Database & CRUD Lead* | Mengembangkan `DatabaseService` (SQLite), model data (`WorkoutModel`, `MemberModel`), serta layar `WorkoutsScreen` (CRUD) dan `MembersScreen`. |
| **Mahasiswa 3** | *Computation & Mathematical Logic Lead* | Mengembangkan logika kalkulasi `BmiScreen`, `WeightConverterScreen`, `AgeCalculatorScreen`, serta unit tests di `test/calculations_test.dart`. |
| **Mahasiswa 4** | *UI/UX, Calendar & QA Lead* | Mengembangkan tema aplikasi `AppTheme`, `StopwatchScreen`, `WetonSakaScreen`, `HelpScreen`, pengujian linter, serta penyusunan dokumentasi. |
