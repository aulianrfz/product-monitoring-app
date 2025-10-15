# PRODUCT MONITORING APP

Proyek ini dibuat sebagai implementasi tugas studi kasus FAJAR dari perusahaan PANDA BIRU.  

Aplikasi terdiri dari:
- **Frontend (Flutter)** untuk aplikasi mobile Android
- **Backend (Laravel)** untuk API login dan laporan

---

## Fitur Utama

### Mobile App (Flutter)
1. **Login**
   - Form username dan password
2. **Absen**
   - Pilihan: masuk kerja / tidak hadir
3. **Daftar Toko**
   - Menampilkan list toko (nama, kode, alamat)
4. **Detail Toko**
   - Dua menu utama: *Produk* dan *Promo*
5. **Daftar Produk**
   - Checkbox untuk menandai produk tersedia / tidak
6. **Promo**
   - Tambah promo baru (nama produk, harga normal, harga promo)
   - Data promo bisa diedit

---

### Backend (Laravel)
- Endpoint:
  - `POST /api/v1/login` → autentikasi user
  - `POST /api/v1/report/:context` → menerima laporan, misalnya `/report/attendance`
  - dan endpoint lainnya sesuai kebutuhan
- Menggunakan database (MySQL / MariaDB)
- Validasi dan struktur JSON response sesuai standar REST API

---

## Solusi Offline Mode

Untuk menghadapi kondisi tanpa koneksi internet, digunakan pendekatan **local persistence**:
1. Alur utama:
- View memanggil ViewModel.
- ViewModel meneruskan ke Repository.
- Repository menentukan apakah ada koneksi internet atau tidak.
2. Jika tidak ada koneksi (offline):
- Repository mengambil data dari penyimpanan lokal (Hive).
- Data yang sudah pernah disimpan saat online akan muncul dari cache, jadi pengguna tetap bisa melihat data tanpa internet.
- Jika pengguna menambah/mengedit data baru saat offline, data disimpan sementara di Hive dengan status “belum tersinkronisasi”.
3. Jika ada koneksi (online):
- Repository mengirim data langsung ke server melalui API.
- Data dari server juga disimpan ke Hive agar tetap bisa diakses saat offline.
- Dengan cara ini, data lokal selalu diperbarui sesuai dengan data di server.
4. Sinkronisasi otomatis:
- Ketika koneksi internet kembali aktif, sistem akan mendeteksi data yang belum tersinkronisasi.
- Data tersebut akan dikirim ke server agar data di aplikasi dan server tetap konsisten.
**Catatan:**
Karena waktu pengembangan yang terbatas, fitur offline belum sepenuhnya selesai. Aplikasi sudah dapat menyimpan dan menampilkan data secara lokal menggunakan Hive, namun proses sinkronisasi otomatis ke server masih dalam tahap perencanaan. Meskipun demikian, arsitektur dan alurnya telah disiapkan agar pengembangan fitur ini dapat dilanjutkan dengan mudah pada tahap berikutnya. Sementara itu, seluruh proses dalam mode online sudah berfungsi sepenuhnya.

---

## Tech Stack
- Mobile: Flutter
- Backend: Laravel 12
- Database: MySQL
- Local Storage: Hive 

---
## Cara Menjalankan

### Backend
```bash
cd laravel-product-monitoring
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
Catatan: pastikan backend berjalan di http://<ip_lokal>:8000, bisa di cek melalui ipconfig

### Mobile
cd flutter_product_monitoring
Atur IP Server di Flutter: cd lib/core/config/app_config.dart
Ubah baseUrl sesuai dengan IP perangkat yang menjalankan backend
flutter pub get
flutter run

