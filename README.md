# 📱 Proyek Flutter + Laravel Back-end

## 📝 Deskripsi Proyek
Proyek ini adalah aplikasi mobile berbasis **Flutter** yang terintegrasi dengan **Laravel** sebagai back-end. Aplikasi ini mencakup fitur **autentikasi**, **CRUD posting**, **like/dislike**, serta fitur **manajemen artis** dengan navigasi yang interaktif.

## 🚀 Teknologi yang Digunakan
- **Flutter** (State Management: Bloc)
- **Laravel** (Framework PHP untuk API Back-end)
- **MySQL** (Database)
- **Postman** (Untuk pengujian API)

---

## 📂 Struktur Proyek

### **Flutter (Front-End)**

```
lib/
├── blocs/                # State Management (Bloc)
│   ├── auth/            # Autentikasi
│   ├── post/            # Post Management
│   ├── artist/          # Manajemen Artis
├── screens/              # Halaman UI
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── artists_screen.dart
├── widgets/              # Komponen Reusable
│   ├── post_card.dart
│   ├── youtube_embed.dart
│   ├── create_post_widget.dart
```

### **Laravel (Back-End)**

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── AuthController.php
│   │   ├── PostController.php
│   │   ├── ArtistController.php
├── Models/
│   ├── User.php
│   ├── Post.php
│   ├── Artist.php
├── database/
│   ├── migrations/
│   │   ├── 2025_02_20_create_posts_table.php
│   │   ├── 2025_02_20_create_artists_table.php
```

---

## 🔧 **Setup Laravel Back-end**

Live Server : https://api-nando.batubhayangkara.com

### 1️⃣ **Clone Repository & Install Dependencies**
```sh
git clone https://github.com/aryanando/test_laravel_api.git
cd repo/backend
composer install
```

### 2️⃣ **Konfigurasi `.env`**
Salin `.env.example` ke `.env`:
```sh
cp .env.example .env
```
Edit file `.env` untuk database:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mydatabase
DB_USERNAME=root
DB_PASSWORD=
```

### 3️⃣ **Generate App Key & Migrate Database**
```sh
php artisan key:generate
php artisan migrate --seed
```

### 4️⃣ **Jalankan Server Laravel**
```sh
php artisan serve --host=0.0.0.0 --port=8081
```
Server API akan berjalan di **http://127.0.0.1:8081**.

---

## 📲 **Setup Flutter Front-End**

### 1️⃣ **Clone Repository & Install Dependencies**
```sh
git clone https://github.com/aryanando/test_app.git
cd test_app
flutter pub get
```

### 2️⃣ **Jalankan Aplikasi di Emulator / Perangkat Fisik**
```sh
flutter run
```

---

## 🛠 **Setup Postman untuk API**

### 1️⃣ **Import Collection Postman**
- **Buka Postman**
- **Klik Import** (File -> Import)
- **Pilih file `Api-Test.postman_collection.json`**

### 2️⃣ **Import Environment untuk API**
- **Buka Postman**
- **Klik Settings (⚙️) -> Environments**
- **Klik Import**
- **Pilih file `Test-API-ENV.postman_environment`**
- **Atur Environment ke `API Laravel`**

### 3️⃣ **Gunakan Endpoint API**
| Endpoint               | Method   | Deskripsi              |
| ---------------------- | -------- | ---------------------- |
| `/api/register`        | `POST`   | Registrasi akun baru   |
| `/api/login`           | `POST`   | Login pengguna         |
| `/api/profile`         | `GET`    | Ambil profil pengguna  |
| `/api/update-profile`  | `POST`   | Update profil pengguna |
| `/api/posts`           | `GET`    | Ambil daftar post      |
| `/api/posts`           | `POST`   | Buat post baru         |
| `/api/posts/{id}/like` | `POST`   | Like/unlike post       |
| `/api/artist`          | `GET`    | Ambil daftar artis     |
| `/api/artist`          | `POST`   | Tambah artis baru      |
| `/api/artist/{id}`     | `PUT`    | Update artis           |
| `/api/artist/{id}`     | `DELETE` | Hapus artis            |

---

**📝 Catatan:** Saya mengucapkan permohonan maaf karena sedikit lambat dalam mengumpulkan proyek ini dikarenakan mengalami musibah dislokasi lutut. Dan maaf karena masih belum menyertakan uji fitur live camera dikarenakan waktu.

## 👨‍💻 **Kontributor**

- **Aryanando** - Backend & API
- **Aryanando** - Flutter Front-end

🚀 **Selamat Coding!** 🔥

