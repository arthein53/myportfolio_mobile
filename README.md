# MyPortfolio Mobile

Aplikasi Flutter multiplatform untuk portofolio pribadi Rafael Arlen Wijanarko.

## Fitur

- Halaman utama berbasis `StatelessWidget`.
- Tiga `InfoCard` yang menampilkan nama lengkap, NPM, dan kelas PBP.
- Menu Lihat Proyek, Tambah Proyek, dan Logout.
- Warna latar yang berbeda untuk setiap kartu menu.
- Umpan balik `SnackBar` untuk setiap tombol yang ditekan.
- Layout responsif yang diuji pada viewport 375 × 812 dan 320 × 568.

## Menjalankan Aplikasi

Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run -d chrome
```

## Verifikasi

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

### Tugas 7

1. **Widget tree dan hubungan parent-child**
   Widget tree adalah susunan hierarkis widget yang membentuk UI Flutter. Parent membungkus dan memberi constraint atau context kepada child. Contohnya, `MaterialApp` memiliki child `MyHomePage`, lalu `MyHomePage` membangun `Scaffold` yang berisi `AppBar` dan body.

2. **Widget yang digunakan dan fungsinya**
   - `MyApp` dan `MaterialApp`: root dan konfigurasi utama aplikasi.
   - `MyHomePage` dan `Scaffold`: halaman utama dan struktur dasarnya.
   - `AppBar`, `Text`, dan `Icon`: menampilkan judul, tulisan, dan ikon.
   - `SingleChildScrollView`: membuat halaman bisa di-scroll.
   - `Column`, `Row`, `Expanded`, `Center`, dan `SizedBox`: mengatur layout dan jarak antar elemen.
   - `LayoutBuilder` dan `GridView.count`: membuat grid menu responsif.
   - `InfoCard`, `Card`, `Container`, `Padding`, dan `FittedBox`: menampilkan informasi profil dengan rapi.
   - `ItemCard`, `Material`, dan `InkWell`: membuat kartu menu yang bisa ditekan.
   - `SnackBar`: memberi pesan setelah tombol ditekan.

3. **Fungsi `MaterialApp`**
   `MaterialApp` menyiapkan tema, navigasi, judul, dan konfigurasi Material lainnya. Widget ini biasanya menjadi root agar konfigurasi tersebut bisa dipakai oleh seluruh widget di bawahnya. Di proyek ini, `MaterialApp` juga menetapkan `MyHomePage` sebagai halaman awal.

4. **Perbedaan `StatelessWidget` dan `StatefulWidget`**
   `StatelessWidget` dipakai jika tampilan tidak memiliki state internal yang berubah, seperti `InfoCard` dan halaman menu ini. `StatefulWidget` dipakai jika UI perlu berubah selama aplikasi berjalan, misalnya pada form, loading, counter, atau data hasil API.

5. **`BuildContext` dan penggunaannya**
   `BuildContext` menunjukkan posisi widget di dalam widget tree. Context digunakan untuk mengakses widget ancestor seperti `Theme`, `Navigator`, atau `ScaffoldMessenger`. Pada proyek ini, context dipakai untuk mengambil warna tema dan menampilkan `SnackBar`.

6. **Hot reload, hot restart, dan full restart**
   Hot reload menerapkan perubahan kode tanpa mereset state aplikasi. Hot restart menjalankan ulang aplikasi dari `main` dan mereset state. Hot restart diperlukan jika perubahan menyentuh inisialisasi atau state awal, sedangkan full restart diperlukan untuk perubahan native, plugin, dependency, atau konfigurasi platform.

## AI Disclosure

Saya menggunakan **GPT 5.6 sol** untuk membantu memahami requirement tugas, menyusun struktur kode Flutter, membuat UI yang responsif, dan menulis test. Hasil yang diberikan AI tetap saya periksa kembali melalui `flutter test` dan `flutter analyze`.
