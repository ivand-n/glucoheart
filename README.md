<div align="center">
  <img src="https://via.placeholder.com/500x150?text=GlucoHeart+Logo" alt="GlucoHeart Logo" width="500">
  
  # GlucoHeart - Kesehatan Digital
  
  [![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/oriontechno/glucoheart_flutter)
  [![Status](https://img.shields.io/badge/status-MVP-yellow.svg)](https://github.com/oriontechno/glucoheart_flutter)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Flutter](https://img.shields.io/badge/Flutter-3.10.0-42A5F5?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0.0-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
  
  Aplikasi digital untuk monitoring dan manajemen kondisi Diabetes Mellitus & Hipertensi
</div>

## 📑 Daftar Isi

- [📱 Gambaran Umum](#-gambaran-umum)
- [✨ Fitur](#-fitur)
- [🖼️ Screenshot](#-screenshot)
- [🚀 Instalasi](#-instalasi)
- [💻 Pengembangan](#-pengembangan)
- [🤝 Kontribusi](#-kontribusi)
- [📜 Lisensi](#-lisensi)

## 📱 Gambaran Umum

**GlucoHeart** adalah aplikasi kesehatan digital yang dirancang untuk membantu pengguna memantau, mengelola, dan memahami kondisi Diabetes Mellitus (DM) dan Hipertensi. Aplikasi ini menggabungkan fitur edukasi, pemeriksaan mandiri, grafik & riwayat, chat dengan tenaga keperawatan, dan forum diskusi komunitas untuk memberikan solusi komprehensif bagi penderita DM dan hipertensi.

Aplikasi ini dikembangkan menggunakan **Flutter** untuk front-end mobile dan **NestJS + PostgreSQL** untuk backend (masih dalam pengembangan).

> 🏗️ **Status Saat Ini:** Versi MVP (Minimum Viable Product)

## ✨ Fitur

### 📊 Fitur MVP (Tersedia Saat Ini)

| Fitur | Deskripsi |
|-------|-----------|
| 🎨 **Splashscreen** | Tampilan awal yang elegan dan profesional |
| 🔐 **Login & Registrasi** | Sistem autentikasi dengan dummy data (backend belum aktif) |
| 🏠 **Beranda** | Dashboard dengan shortcut ke fitur utama |
| 🧭 **Bottom Navigation** | Navigasi responsif dengan 4 tab utama |
| 👤 **Profil Pengguna** | Halaman profil dengan data dummy |
| 🚪 **Logout** | Fitur keluar dari aplikasi dengan konfirmasi |

### 🔮 Fitur Lengkap (Roadmap)

#### 📱 Mobile App

| Kategori | Fitur |
|----------|-------|
| **Autentikasi** | • Login & Registrasi<br>• Verifikasi Email<br>• Lupa Password<br>• Otentikasi 2 Faktor |
| **Profil** | • Data Pribadi<br>• Riwayat Medis<br>• Alergi & Kondisi Khusus<br>• Pengaturan Notifikasi |
| **Pemeriksaan** | • Input Gula Darah<br>• Input Tekanan Darah<br>• Input Berat Badan<br>• Reminder Pemeriksaan |
| **Grafik & Analitik** | • Tren Gula Darah<br>• Tren Tekanan Darah<br>• Laporan Bulanan<br>• Ekspor Data |
| **Edukasi** | • Artikel Kesehatan<br>• Video Edukasi<br>• Tips Harian<br>• Resep Makanan Sehat |
| **Konsultasi** | • Chat dengan Perawat/Dokter<br>• Jadwal Konsultasi<br>• Riwayat Konsultasi |
| **Komunitas** | • Forum Diskusi<br>• Grup Dukungan<br>• Sharing Pengalaman<br>• Event & Webinar |
| **Utilitas** | • Pengingat Minum Obat<br>• Kalkulator Dosis Insulin<br>• Scan Makanan<br>• Integrasi dengan Perangkat |

#### 🖥️ Web Admin

| Kategori | Fitur |
|----------|-------|
| **Manajemen Pengguna** | • Daftar Pengguna<br>• Detail Profil<br>• Statistik Pengguna<br>• Pengelolaan Akses |
| **Konten** | • Manajemen Artikel<br>• Upload Video<br>• Kategori Konten<br>• Editor Rich Text |
| **Monitoring** | • Dashboard Analitik<br>• Tren Pengguna<br>• Laporan Penggunaan<br>• Notifikasi Sistem |
| **Konsultasi** | • Manajemen Jadwal Tenaga Medis<br>• Riwayat Konsultasi<br>• Tindak Lanjut<br>• Rating & Feedback |
| **Komunitas** | • Moderasi Forum<br>• Manajemen Grup<br>• Tindakan Moderasi<br>• Laporan Pelanggaran |
| **Sistem** | • Konfigurasi Aplikasi<br>• Backup & Restore<br>• Log Aktivitas<br>• Keamanan & Enkripsi |

## 🖼️ Screenshot

<div align="center">
  <img src="https://via.placeholder.com/200x400?text=Splash+Screen" alt="Splash Screen" width="200">
  <img src="https://via.placeholder.com/200x400?text=Login+Screen" alt="Login Screen" width="200">
  <img src="https://via.placeholder.com/200x400?text=Home+Screen" alt="Home Screen" width="200">
  <img src="https://via.placeholder.com/200x400?text=Profile+Screen" alt="Profile Screen" width="200">
</div>

## 🚀 Instalasi

### Prasyarat

- [Flutter](https://flutter.dev/docs/get-started/install) (versi 3.10.0 atau lebih baru)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/) dengan ekstensi Flutter
- Android SDK (untuk pengembangan Android)
- Xcode (untuk pengembangan iOS - hanya macOS)
- Git

### Langkah-langkah

1. **Clone repositori**

   ```bash
   git clone https://github.com/oriontechno/glucoheart_flutter.git
   cd glucoheart_flutter
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**

   ```bash
   flutter run
   ```

   Atau melalui IDE Anda:
   - VS Code: Tekan `F5` atau klik tombol Run
   - Android Studio: Klik tombol Run

## 💻 Pengembangan

### Struktur Folder

```
lib/
├── config/               # Konfigurasi aplikasi
│   ├── routes/           # Definisi rute
│   ├── themes/           # Tema aplikasi
│   └── constants/        # Konstanta aplikasi
├── core/                 # Core functionality
│   ├── exceptions/       # Exception handling
│   ├── network/          # HTTP client, interceptors
│   └── utils/            # Utility functions
├── data/                 # Data layer
│   ├── datasources/      # Remote dan local data sources
│   ├── models/           # Model data
│   └── repositories/     # Implementasi repository
├── domain/               # Domain layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
├── presentation/         # UI Layer
│   ├── common/           # Shared widgets
│   ├── features/         # Feature-based screens
│   └── providers/        # Riverpod providers
└── main.dart             # Entry point
```

### State Management

Proyek ini menggunakan [Riverpod](https://riverpod.dev/) untuk state management karena:
- Type safety yang lebih baik
- Pengelolaan dependensi yang mudah
- Testability yang lebih baik
- Dukungan untuk hot reload

### Coding Style

- Ikuti [Effective Dart](https://dart.dev/guides/language/effective-dart) untuk pedoman style Dart
- Gunakan `camelCase` untuk variabel dan fungsi
- Gunakan `PascalCase` untuk nama kelas dan enum
- Tambahkan komentar untuk kode yang kompleks

## 🤝 Kontribusi

Kami sangat mengapresiasi kontribusi ke proyek GlucoHeart! Berikut adalah langkah-langkah untuk berkontribusi:

1. Fork repositori
2. Buat branch fitur baru (`git checkout -b feature/amazing-feature`)
3. Commit perubahan Anda (`git commit -m 'Add some amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Buka Pull Request

### Guidelines

- Pastikan kode Anda mengikuti coding style proyek
- Tambahkan unit test untuk fitur baru
- Update dokumentasi jika diperlukan
- Pastikan semua test lulus sebelum membuat PR

## 📜 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE) - lihat file LICENSE untuk detail lebih lanjut.

---

<div align="center">
  <p>Dibuat dengan ❤️ oleh Tim XHARP</p>
  <p>
    <a href="https://flutter.dev">Flutter</a> •
    <a href="https://dart.dev">Dart</a> •
    <a href="https://nestjs.com">NestJS</a> •
    <a href="https://www.postgresql.org">PostgreSQL</a>
  </p>
</div>
