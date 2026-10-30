# Dokumentasi Lengkap REST API v4 - Mobile App Terapis Mom N Jo
**Spesifikasi Teknis, Panduan Integrasi Frontend, Katalog Endpoint, dan Penanganan Error State Lengkap**

Dokumentasi ini adalah acuan resmi bagi tim Frontend (Mobile Developer Flutter / React Native / Android Native / iOS) untuk mengintegrasikan backend `api_terapis_v4`.

---

## 1. Arsitektur & Konvensi Umum

### 1.1. Base URL
```http
https://dashboard.momnjo.my.id/dev/api_terapis_v4
```
- **Default Timezone:** `Asia/Jakarta` (WIB / UTC+7).
- **Default Format Data:** JSON UTF-8 (`application/json; charset=utf-8`).

### 1.2. Standard Request Headers
Setiap request ke endpoint terproteksi wajib menyertakan header berikut:
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <JWT_TOKEN>
```

### 1.3. Standard Response Envelope
Semua endpoint `api_terapis_v4` mengembalikan struktur JSON konsisten:

#### A. Response Sukses (HTTP 200 / 201)
```json
{
  "status": true,
  "message": "Deskripsi keberhasilan operasi",
  "data": { ... }
}
```

#### B. Response Error (HTTP 4xx / 5xx)
```json
{
  "status": false,
  "message": "Pesan deskripsi error yang ramah pengguna",
  "data": null
}
```
> [!NOTE]
> Pada kondisi error tertentu (misalnya `HTTP 409 Conflict`), field `data` dapat berisi rincian data verifikasi (`need_confirmation: true`, `current_terapis`, dll.) untuk memandu antarmuka pengguna frontend.

### 1.4. Health Check (Ping)
- **Endpoint:** `GET /` atau `GET /index.php`
- **Auth:** Public (Tanpa token)
- **Fungsi:** Verifikasi bahwa service API aktif dan online.

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "API Terapis v4 Momnjo is online and ready.",
  "data": {
    "version": "4.0.0",
    "service": "api_terapis_v4",
    "timestamp": "2026-10-30 11:45:00",
    "timezone": "Asia/Jakarta"
  }
}
```

---

## 2. Arsitektur Error Handling & Standar HTTP Status Code

API menggunakan kode status HTTP standar RFC 7231 untuk membedakan kategori kondisi:

| HTTP Status | Definisi | Keterangan untuk Frontend |
|---|---|---|
| **200 OK** | Sukses | Request berhasil diproses, data dikembalikan di field `data`. |
| **201 Created** | Data Tersimpan | Resource baru berhasil dibuat (misal Check-In absensi). |
| **400 Bad Request** | Kesalahan Logika / State | Parameter tidak valid, transisi status tidak diizinkan, atau pelanggaran aturan bisnis. |
| **401 Unauthorized** | Autentikasi Gagal / Expired | Token tidak ada, token salah/kadaluarsa, atau username/password login salah. |
| **403 Forbidden** | Akses Ditolak | Akun diblokir (`blokir == 'Y'`), atau user bukan berlevel `'terapis'`. |
| **404 Not Found** | Data Tidak Ditemukan | Resource yang diminta (Job, Gerai, User) tidak ditemukan di database. |
| **405 Method Not Allowed** | HTTP Method Salah | Mengakses endpoint GET dengan POST, atau sebaliknya. |
| **409 Conflict** | Butuh Konfirmasi (Warning) | Terjadi benturan status (contoh: job sedang diproses terapis lain, butuh konfirmasi force reassign). |
| **422 Unprocessable Entity** | Validasi Input Gagal | Parameter wajib kosong, format email salah, atau password kurang dari 6 karakter. |
| **500 Internal Error** | Kendala Server / Database | Server database MySQL down atau kegagalan koneksi PDO. |

### 2.1. Standar Global Error Interceptor di Frontend (Mobile)
Disarankan mengimplementasikan HTTP Interceptor (Dio di Flutter, Axios di React Native):

```typescript
// Contoh Logika Global HTTP Interceptor di Frontend
axios.interceptors.response.use(
  (response) => response,
  (error) => {
    if (!error.response) {
      // Masalah Jaringan / Offline
      showToast("Koneksi internet bermasalah. Silakan periksa jaringan Anda.");
      return Promise.reject(error);
    }

    const { status, data } = error.response;
    const message = data?.message || "Terjadi kesalahan pada sistem.";

    switch (status) {
      case 401:
        // Token hangus / salah password
        showToast(message);
        if (!isLoginScreen()) {
          authStorage.clearToken();
          navigation.resetTo("LoginScreen");
        }
        break;

      case 403:
        // Akun dinonaktifkan / bukan terapis
        showAlertDialog("Akses Ditolak", message, () => {
          authStorage.clearToken();
          navigation.resetTo("LoginScreen");
        });
        break;

      case 404:
        showToast(message);
        break;

      case 409:
        // Khusus penanganan dialog konfirmasi (handled locally by caller)
        break;

      case 422:
        // Validasi input form
        showToast(message);
        break;

      case 500:
        showToast("Terjadi kendala pada server. Silakan hubungi admin.");
        break;

      default:
        showToast(message);
        break;
    }

    return Promise.reject(error);
  }
);
```

---

## 3. Katalog Endpoint, Error States & Handling Lengkap

---

### Endpoint 1: `POST /login.php`
- **Tujuan:** Autentikasi terapis untuk mendapatkan token JWT.
- **Auth:** Public (Tanpa token).
- **Request Body (JSON):**
  ```json
  {
    "username": "siti.nurhaliza",
    "password": "password123"
  }
  ```
  *(Catatan: Mendukung juga key legacy `"a"` untuk username dan `"b"` untuk password).*

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Login berhasil",
  "data": {
    "username": "siti.nurhaliza",
    "nama_lengkap": "Siti Nurhaliza",
    "nickname": "Siti",
    "email": "siti@momnjo.com",
    "no_telp": "081234567890",
    "foto": "siti.jpg",
    "id_gerai": 1,
    "nama_gerai": "Mom N Jo Dharmawangsa",
    "kode_gerai": "JKS01",
    "id_pegawai": 15,
    "position": "Therapist Senior",
    "work_in_branch": "Dharmawangsa"
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **405 Method Not Allowed** | Request dikirim bukan dengan HTTP `POST` (misal `GET`). | `{"status": false, "message": "Metode request tidak diizinkan. Gunakan POST.", "data": null}` | Pastikan HTTP Client menggunakan method `POST`. |
| **422 Unprocessable Entity** | Field `username` atau `password` kosong/whitespace. | `{"status": false, "message": "Username dan password wajib diisi", "data": null}` | Validasi form client-side sebelum request; tampilkan helper error text di bawah input field. |
| **401 Unauthorized** | Username tidak terdaftar atau level akun bukan `'terapis'`. | `{"status": false, "message": "Username atau password salah", "data": null}` | Tampilkan error banner / snackbar merah "Username atau password salah". Kosongkan field password. |
| **401 Unauthorized** | Password yang diinput tidak cocok dengan hash database. | `{"status": false, "message": "Username atau password salah", "data": null}` | Tampilkan snackbar "Username atau password salah". Jaga keamanan dengan tidak memberitahukan field mana yang salah. |
| **403 Forbidden** | Akun terapis dalam status diblokir (`blokir != 'N'`). | `{"status": false, "message": "Akun Anda tidak aktif atau diblokir. Silakan hubungi admin.", "data": null}` | Tampilkan modal alert popup bertombol "Hubungi Admin Gerai" untuk mengarahkan ke WhatsApp Admin. |
| **500 Internal Error** | Database server terputus / gagal terhubung. | `{"status": false, "message": "Gagal terhubung ke database: ...", "data": null}` | Tampilkan dialog "Server sedang mengalami gangguan, coba lagi beberapa saat". |

---

### Endpoint 2: `GET /me.php` (Profil & Status Absensi Terkini)
- **Alias Endpoint:** `GET /profile.php`, `GET /user.php`
- **Tujuan:** Mengambil profil lengkap terapis yang sedang login dan status absensinya saat ini.
- **Auth:** Wajib Bearer Token.

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Data profil terapis berhasil diambil",
  "data": {
    "user": {
      "username": "siti.nurhaliza",
      "nama_lengkap": "Siti Nurhaliza",
      "nickname": "Siti",
      "email": "siti@momnjo.com",
      "no_telp": "081234567890",
      "foto": "siti.jpg",
      "id_gerai": 1,
      "nama_gerai": "Mom N Jo Dharmawangsa",
      "kode_gerai": "JKS01",
      "id_pegawai": 15,
      "position": "Therapist Senior",
      "work_in_branch": "Dharmawangsa"
    },
    "attendance": {
      "status_duty": "on_duty",
      "waktu_sekarang": "2026-10-30 11:45:00",
      "last_record": {
        "id_absensi": 105,
        "username_terapis": "siti.nurhaliza",
        "action": "check_in",
        "waktu": "2026-10-30 08:55:00",
        "lokasi": "-6.200000, 106.816666",
        "catatan": null
      },
      "today_summary": {
        "date": "2026-10-30",
        "first_check_in": "2026-10-30 08:55:00",
        "last_check_out": null,
        "records_count": 1
      }
    }
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Header `Authorization: Bearer <token>` tidak disertakan atau token kadaluarsa (`exp < now`). | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Hapus token dari storage lokal dan arahkan pengguna kembali ke layar Login. |
| **401 Unauthorized** | Username di dalam token payload tidak ditemukan lagi di database. | `{"status": false, "message": "Unauthorized: Pengguna tidak ditemukan", "data": null}` | Logout paksa, hapus session, arahkan ke Login. |
| **403 Forbidden** | Akun terapis dinonaktifkan oleh kasir/admin saat sesi sedang berjalan. | `{"status": false, "message": "Forbidden: Akun Anda telah dinonaktifkan", "data": null}` | Tampilkan alert dialog "Akun Anda telah dinonaktifkan", lalu logout paksa. |
| **403 Forbidden** | Role user bukan `terapis`. | `{"status": false, "message": "Forbidden: Hak akses bukan terapis", "data": null}` | Logout paksa. |
| **405 Method Not Allowed** | Request dikirim menggunakan method selain `GET` atau `POST`. | `{"status": false, "message": "Metode request tidak diizinkan. Gunakan GET atau POST.", "data": null}` | Pastikan menggunakan HTTP `GET`. |

---

### Endpoint 3: `POST /me.php` atau `POST /update_profile.php` (Update Data Diri & Password)
- **Tujuan:** Memperbarui data diri (nama lengkap, no telp, email, foto, alamat) dan/atau mengganti password.
- **Auth:** Wajib Bearer Token.
- **Mendukung Method:** `POST`, `PUT`, `PATCH`.
- **Request Body (JSON):**
  ```json
  {
    "nama_lengkap": "Siti Nurhaliza, A.Md.",
    "email": "siti.baru@momnjo.com",
    "no_telp": "081299998888",
    "address": "Jl. Wijaya Timur No. 12, Jakarta Selatan",
    "password_lama": "password123",
    "password_baru": "rahasia2026"
  }
  ```
  *(Catatan: Field `username`, `id_gerai`, `level`, dan `blokir` diproteksi secara otomatis di sisi backend dan tidak dapat dimanipulasi).*

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Profil data diri berhasil diperbarui",
  "data": {
    "username": "siti.nurhaliza",
    "nama_lengkap": "Siti Nurhaliza, A.Md.",
    "nickname": "Siti",
    "email": "siti.baru@momnjo.com",
    "no_telp": "081299998888",
    "foto": "siti.jpg",
    "address": "Jl. Wijaya Timur No. 12, Jakarta Selatan",
    "id_gerai": 1,
    "nama_gerai": "Mom N Jo Dharmawangsa",
    "kode_gerai": "JKS01",
    "id_pegawai": 15,
    "position": "Therapist Senior",
    "work_in_branch": "Dharmawangsa"
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Token hilang / kadaluarsa. | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Redirect ke Login. |
| **403 Forbidden** | Akun dinonaktifkan (`blokir != 'N'`). | `{"status": false, "message": "Forbidden: Akun Anda telah dinonaktifkan", "data": null}` | Logout paksa. |
| **422 Unprocessable Entity** | Request body kosong atau tidak ada field yang dapat diupdate. | `{"status": false, "message": "Tidak ada data yang dikirim untuk diupdate", "data": null}` | Disable tombol "Simpan" jika pengguna belum mengubah isi formulir. |
| **422 Unprocessable Entity** | Format email tidak valid (`FILTER_VALIDATE_EMAIL` gagal). | `{"status": false, "message": "Format email tidak valid", "data": null}` | Tampilkan inline error text merah di bawah input email: "Format email tidak valid". |
| **422 Unprocessable Entity** | `password_baru` diisi kurang dari 6 karakter. | `{"status": false, "message": "Password baru minimal 6 karakter", "data": null}` | Validasi panjang karakter di frontend (`password.length >= 6`); tampilkan error text di bawah input password baru. |
| **400 Bad Request** | `password_lama` tidak cocok dengan password yang sedang aktif di database. | `{"status": false, "message": "Password lama tidak sesuai", "data": null}` | Tampilkan inline error pada kolom Password Lama: "Password lama tidak sesuai". Fokuskan kursor ke input tersebut. |
| **404 Not Found** | Record user terapis tidak ditemukan saat query update. | `{"status": false, "message": "Pengguna tidak ditemukan", "data": null}` | Sesi tidak valid; logout paksa. |

---

### Endpoint 4: `GET /gerai.php` (Kontak & WhatsApp Gerai)
- **Alias Endpoint:** `GET /kontak_gerai.php`, `GET /wa_gerai.php`
- **Tujuan:** Mengambil detail kontak telepon dan WhatsApp admin/frontdesk gerai untuk tombol bantuan darurat / koordinasi operasional.
- **Auth:** Opsional (Bisa diakses dengan Bearer Token untuk otomatis mengambil gerai asal terapis, atau via query parameter `?id_gerai=...` atau `?list=1`).

#### A. Request Single Gerai (Berdasarkan Token atau `?id_gerai=1`)
```http
GET /gerai.php
Authorization: Bearer <JWT_TOKEN>
```
#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Kontak WhatsApp gerai berhasil diambil",
  "data": {
    "id_gerai": 1,
    "nama_gerai": "Mom N Jo Dharmawangsa",
    "kode_gerai": "JKS01",
    "kontak_wa": "08111222333",
    "wa_number": "628111222333",
    "wa_link": "https://wa.me/628111222333?text=Halo%20Admin%20Mom%20N%20Jo%20Dharmawangsa...",
    "kontak_gerai": "021-72780000",
    "lokasi_gerai": "Jl. Dharmawangsa IV No. 8",
    "kota": "Jakarta Selatan",
    "provinsi": "DKI Jakarta"
  }
}
```

#### B. Request Seluruh Gerai Aktif (`?list=1`)
```http
GET /gerai.php?list=1
```
#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Daftar kontak gerai berhasil diambil",
  "data": {
    "total": 3,
    "gerai": [
      {
        "id_gerai": 1,
        "nama_gerai": "Mom N Jo Dharmawangsa",
        "kode_gerai": "JKS01",
        "wa_number": "628111222333",
        "wa_link": "https://wa.me/628111222333?text=..."
      }
    ]
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **405 Method Not Allowed** | Request dikirim dengan method selain `GET`. | `{"status": false, "message": "Metode request tidak diizinkan. Gunakan GET.", "data": null}` | Pastikan menggunakan method `GET`. |
| **400 Bad Request** | Request tanpa token autentikasi dan tidak menyertakan parameter `?id_gerai=...` atau `?list=1`. | `{"status": false, "message": "Parameter 'id_gerai' wajib diisi jika tidak menyertakan token autentikasi terapis.", "data": null}` | Sertakan header `Authorization: Bearer <token>` atau sertakan parameter `?id_gerai=<id>` pada URL. |
| **404 Not Found** | `id_gerai` yang diminta tidak ditemukan di database atau gerai sedang dinonaktifkan (`blokir = 'Y'`). | `{"status": false, "message": "Data gerai tidak ditemukan atau sedang dinonaktifkan.", "data": null}` | Tampilkan pesan info "Kontak gerai belum tersedia" dan sembunyikan tombol WhatsApp. |

---

### Endpoint 5: `GET /absensi.php` (Status & Riwayat Absensi)
- **Tujuan:**
  1. Default: Cek status terkini (`on_duty` / `off_duty`) dan ringkasan hari ini.
  2. `?type=history`: Mengambil riwayat absensi terapis.
- **Auth:** Wajib Bearer Token.

#### A. Cek Status Terkini: `GET /absensi.php`
#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Status absensi berhasil diambil",
  "data": {
    "username": "siti.nurhaliza",
    "status_duty": "on_duty",
    "waktu_sekarang": "2026-10-30 11:45:00",
    "last_record": {
      "id_absensi": 105,
      "username_terapis": "siti.nurhaliza",
      "action": "check_in",
      "waktu": "2026-10-30 08:55:00",
      "lokasi": "-6.200000, 106.816666",
      "catatan": null
    },
    "today_summary": {
      "date": "2026-10-30",
      "first_check_in": "2026-10-30 08:55:00",
      "last_check_out": null,
      "records_count": 1
    }
  }
}
```

#### B. Riwayat Absensi: `GET /absensi.php?type=history&bulan=2026-10&limit=30`
#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Riwayat absensi berhasil diambil",
  "data": {
    "username": "siti.nurhaliza",
    "total": 2,
    "history": [
      {
        "id_absensi": 105,
        "action": "check_in",
        "waktu": "2026-10-30 08:55:00",
        "lokasi": "-6.200000, 106.816666",
        "catatan": null
      },
      {
        "id_absensi": 104,
        "action": "check_out",
        "waktu": "2026-10-29 23:59:59",
        "lokasi": "-6.200000, 106.816666",
        "catatan": "Lupa Offduty (Human Error)"
      }
    ]
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Token hilang / kadaluarsa. | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Redirect ke Login. |
| **403 Forbidden** | Akun diblokir / bukan terapis. | `{"status": false, "message": "Forbidden: ...", "data": null}` | Logout paksa. |
| **405 Method Not Allowed** | Request dikirim bukan dengan method `GET` atau `POST`. | `{"status": false, "message": "Metode HTTP tidak diizinkan. Gunakan GET atau POST.", "data": null}` | Pastikan menggunakan HTTP `GET`. |

---

### Endpoint 6: `POST /absensi.php` atau `POST /store_absensi.php` (Check-In & Check-Out)
- **Tujuan:** Melakukan Check-In (On Duty) atau Check-Out (Off Duty).
- **Aturan Bisnis Penting:**
  - **Tanpa Foto Selfie:** Tidak memerlukan upload gambar selfie.
  - **Lokasi Opsional:** Menerima koordinat GPS lat,long.
  - **Auto-Checkout:** Jika kemarin terapis lupa check-out, sistem otomatis melakukan check-out jam 23:59:59 dengan catatan `'Lupa Offduty (Human Error)'`.
- **Auth:** Wajib Bearer Token.
- **Request Body (JSON):**
  ```json
  {
    "action": "check_in",
    "lokasi": "-6.200000, 106.816666",
    "catatan": "Masuk shift pagi"
  }
  ```

#### Response Sukses (HTTP 201 Created)
```json
{
  "status": true,
  "message": "Berhasil Check-In.",
  "data": {
    "id_absensi": 106,
    "action": "check_in",
    "status_duty": "on_duty",
    "waktu": "2026-10-30 08:55:00",
    "lokasi": "-6.200000, 106.816666",
    "catatan": "Masuk shift pagi"
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Token hilang / kadaluarsa. | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Redirect ke Login. |
| **403 Forbidden** | Akun dinonaktifkan. | `{"status": false, "message": "Forbidden: Akun Anda telah dinonaktifkan", "data": null}` | Logout paksa. |
| **405 Method Not Allowed** | Request menggunakan method selain `POST`. | `{"status": false, "message": "Metode HTTP tidak diizinkan. Gunakan GET atau POST.", "data": null}` | Gunakan method `POST`. |
| **422 Unprocessable Entity** | Parameter `action` kosong atau tidak ada. | `{"status": false, "message": "Parameter 'action' wajib diisi ('check_in' atau 'check_out').", "data": null}` | Pastikan payload mengirim `"action": "check_in"` atau `"action": "check_out"`. |
| **400 Bad Request** | Parameter `action` bukan `'check_in'` atau `'check_out'`. | `{"status": false, "message": "Action tidak valid. Gunakan 'check_in' atau 'check_out'.", "data": null}` | Periksa penulisan string action di frontend (lowercase). |
| **400 Bad Request** | Terapis mengirim `check_in`, padahal status saat ini sudah `on_duty`. | `{"status": false, "message": "Anda sudah On Duty. Harap Check-Out terlebih dahulu.", "data": null}` | Sembunyikan tombol Check-In saat status `on_duty`. Jika error ini muncul (karena race condition), panggil `GET /me.php` untuk sinkronisasi state UI ke On Duty. |
| **400 Bad Request** | Terapis mengirim `check_out`, padahal status saat ini sudah `off_duty`. | `{"status": false, "message": "Anda sedang Off Duty. Harap Check-In terlebih dahulu.", "data": null}` | Sembunyikan tombol Check-Out saat status `off_duty`. Sinkronisasi state UI ke Off Duty. |

---

### Endpoint 7: `GET /jobs.php` (Daftar Job & Detail 1 Job)
- **Tujuan:**
  1. Default: Mengambil daftar penugasan treatment terapis aktif.
  2. Single Job Detail: `GET /jobs.php?id=<id_job_status>`.
- **Query Filter Opsional:**
  - `status`: `'active'` (default: Menunggu + Arrived + Proses), `'all'`, `'Menunggu'`, `'Arrived'`, `'Proses'`, `'Selesai'`.
  - `kategori`: `'onsite'` atau `'homecare'`.
  - `tgl`: Filter tanggal pengerjaan (contoh: `2026-10-30`).
- **Auth:** Wajib Bearer Token.

#### A. Request List: `GET /jobs.php?status=active`
#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Daftar job berhasil diambil.",
  "data": {
    "total": 1,
    "filter_applied": {
      "status": "active",
      "kategori": null,
      "tgl": null
    },
    "jobs": [
      {
        "id_job_status": 45,
        "id_transaksi_detail_rowid": 128,
        "id_transaksi": "TRX-20261030-0001",
        "id_booking": "BKG-0012",
        "kategori_layanan": "homecare",
        "status_layanan": "Menunggu",
        "terapis": "siti.nurhaliza",
        "durasi_standar": 90,
        "waktu_arrived": null,
        "waktu_mulai": null,
        "waktu_selesai": null,
        "is_paused": false,
        "paused_total_seconds": 0,
        "customer": {
          "id_customer": "CUST-0089",
          "fullname": "Ibu Aurelia",
          "phone": "081288887777",
          "alamat_domisili": "Jl. Senopati No. 45, Kebayoran Baru, Jakarta Selatan"
        },
        "item": {
          "product_id": "PRD-001",
          "product_name": "Mom Massage & Scrub 90 Menit",
          "quantity": 1,
          "satuan": "Menit"
        },
        "transaksi": {
          "tgl_transaksi": "2026-10-30",
          "status_transaksi": "Open",
          "gerai": "JKS01",
          "nama_gerai": "Mom N Jo Dharmawangsa"
        },
        "timer": {
          "durasi_standar_detik": 5400,
          "elapsed_seconds": 0,
          "remaining_seconds": 5400,
          "is_paused": false
        }
      }
    ]
  }
}
```

#### B. Request Detail: `GET /jobs.php?id=45`
Mengembalikan 1 objek detail job lengkap beserta data rekam medis terakhir.

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Token hilang / kadaluarsa. | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Redirect ke Login. |
| **403 Forbidden** | Akun dinonaktifkan. | `{"status": false, "message": "Forbidden: Akun Anda telah dinonaktifkan", "data": null}` | Logout paksa. |
| **404 Not Found** | `GET /jobs.php?id=<id>`: ID job tidak ada di database ATAU job tersebut ditugaskan ke terapis lain (`terapis != $username`). | `{"status": false, "message": "Job tidak ditemukan atau Anda tidak memiliki akses ke job ini.", "data": null}` | Tampilkan dialog "Job tidak ditemukan atau telah dialihkan", lalu refresh daftar job dan arahkan kembali ke layar List Job. |
| **405 Method Not Allowed** | Request dikirim bukan dengan method `GET` atau `POST`. | `{"status": false, "message": "Metode HTTP tidak didukung.", "data": null}` | Gunakan method `GET`. |

---

### Endpoint 8: `POST /jobs.php` (Aksi Siklus Pengerjaan Treatment Terapis)
- **Tujuan:** Menjalankan tahapan alur layanan dari Tiba di Lokasi, Cek Rekam Medis, Mulai Treatment (Timer), Pause, Resume, hingga Selesai.
- **Auth:** Wajib Bearer Token Terapis.
- **Format Body (JSON):**
  ```json
  {
    "id_job_status": 45,
    "action": "arrived | rekam_medis | start | pause | resume | complete"
  }
  ```

---

#### 8.1. Action: `arrived` (Tiba di Lokasi - Khusus Homecare)
```json
{
  "id_job_status": 45,
  "action": "arrived",
  "catatan": "Sudah tiba di lobby apartemen"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Berhasil memperbarui status: Tiba di Lokasi.",
  "data": {
    "status": "success",
    "message": "Berhasil memperbarui status: Tiba di Lokasi.",
    "status_layanan": "Arrived",
    "waktu_arrived": "2026-10-30 09:15:00"
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job; job mungkin sudah dialihkan. |
| **400 Bad Request** | Mencoba action `arrived` pada layanan `onsite` (room gerai). | `{"status": false, "message": "Status Arrived hanya berlaku untuk layanan Homecare.", "data": null}` | Sembunyikan tombol "Tiba di Lokasi" untuk job onsite (onsite langsung ke Start Treatment). |
| **400 Bad Request** | Status job saat ini bukan `'Menunggu'` (misal sudah `'Arrived'`, `'Proses'`, atau `'Selesai'`). | `{"status": false, "message": "Job saat ini berstatus '<status>', tidak dapat diset Arrived.", "data": null}` | Sinkronkan status job dari server dan sesuaikan tombol aksi di antarmuka. |

---

#### 8.2. Action: `rekam_medis` / `health_check` (Simpan Cek Kesehatan / Catatan)
Dapat diisi sebelum atau saat treatment berlangsung. Bersifat opsional / dapat dilewati (skippable).
```json
{
  "id_job_status": 45,
  "action": "rekam_medis",
  "tekanan_darah": "120/80",
  "suhu_tubuh": "36.5",
  "keluhan": "Pegal pada area pundak dan leher",
  "alergi": "Tidak ada",
  "catatan_khusus": "Tekanan pijat sedang"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Rekam medis berhasil disimpan.",
  "data": {
    "status": "success",
    "message": "Rekam medis berhasil disimpan.",
    "id_medical_check": 88
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job. |

---

#### 8.3. Action: `start` (Mulai Treatment & Jalankan Timer)
```json
{
  "id_job_status": 45,
  "action": "start"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Treatment dimulai. Timer aktif.",
  "data": {
    "status": "success",
    "message": "Treatment dimulai. Timer aktif.",
    "status_layanan": "Proses",
    "waktu_mulai": "2026-10-30 09:20:00",
    "durasi_standar": 90
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job. |
| **400 Bad Request** | Treatment sudah dalam status berjalan (`status_layanan == 'Proses'`). | `{"status": false, "message": "Treatment sudah dalam proses berjalan.", "data": null}` | Set status UI menjadi "Proses", jalankan local interval timer, tampilkan tombol Pause dan Selesai. |
| **400 Bad Request** | Treatment sudah dalam status selesai (`status_layanan == 'Selesai'`). | `{"status": false, "message": "Treatment sudah selesai.", "data": null}` | Kunci kontrol pengerjaan; tampilkan badge hijau "Selesai". |

---

#### 8.4. Action: `pause` (Jeda Sementara Timer)
```json
{
  "id_job_status": 45,
  "action": "pause"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Timer berhasil di-pause.",
  "data": {
    "status": "success",
    "message": "Timer berhasil di-pause.",
    "is_paused": true,
    "pause_started_at": "2026-10-30 09:45:00"
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job. |
| **400 Bad Request** | Treatment tidak dalam status `'Proses'` (misal masih `'Menunggu'` atau sudah `'Selesai'`). | `{"status": false, "message": "Hanya treatment yang sedang berjalan (Proses) yang dapat di-pause.", "data": null}` | Disable tombol Pause jika status bukan 'Proses'. |
| **400 Bad Request** | Timer saat ini sudah dalam keadaan pause (`is_paused == 1`). | `{"status": false, "message": "Timer saat ini sudah dalam keadaan pause.", "data": null}` | Hentikan local interval timer, ubah tombol menjadi "Lanjutkan (Resume)". |

---

#### 8.5. Action: `resume` (Lanjutkan Timer Treatment)
```json
{
  "id_job_status": 45,
  "action": "resume"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Timer berhasil di-resume.",
  "data": {
    "status": "success",
    "message": "Timer berhasil di-resume.",
    "is_paused": false,
    "paused_total_seconds": 300
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job. |
| **400 Bad Request** | Treatment tidak sedang dalam status `'Proses'`. | `{"status": false, "message": "Treatment tidak sedang dalam proses.", "data": null}` | Disable tombol Resume. |
| **400 Bad Request** | Timer tidak sedang di-pause (`is_paused != 1`). | `{"status": false, "message": "Timer tidak sedang di-pause.", "data": null}` | Mulai kembali local interval timer; ubah tombol menjadi "Jeda (Pause)". |

---

#### 8.6. Action: `complete` (Selesaikan Treatment oleh Terapis)
```json
{
  "id_job_status": 45,
  "action": "complete",
  "catatan": "Treatment selesai dengan lancar, customer merasa puas"
}
```

#### Response Sukses (HTTP 200)
```json
{
  "status": true,
  "message": "Treatment berhasil diselesaikan.",
  "data": {
    "status": "success",
    "message": "Treatment berhasil diselesaikan.",
    "status_layanan": "Selesai",
    "waktu_selesai": "2026-10-30 10:50:00"
  }
}
```

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **400 Bad Request** | ID Job tidak ada atau bukan milik terapis yang login. | `{"status": false, "message": "Job tidak ditemukan atau bukan milik Anda.", "data": null}` | Refresh daftar job. |
| **400 Bad Request** | Job ini sudah berstatus `'Selesai'`. | `{"status": false, "message": "Job ini sudah berstatus Selesai.", "data": null}` | Tampilkan dialog konfirmasi "Treatment telah selesai", hentikan timer, arahkan kembali ke Daftar Job Aktif. |

---

### Endpoint 9: Aksi Kasir / Back-Office pada `POST /jobs.php`

Digunakan oleh sistem integrasi web kasir atau back-office:

#### 9.1. Action: `sync` (Sinkronisasi Nota ke Job Terapis)
- **Body:** `{"action": "sync", "id_transaksi": "TRX-20261030-0001"}`
- **Error (HTTP 400):** Parameter `id_transaksi` wajib diisi.

#### 9.2. Action: `reassign` (Pengalihan Job Terapis dengan Proteksi Status Proses)
- **Body:** `{"action": "reassign", "rowid": 128, "terapis": "siti.nurhaliza", "force": false}`

#### Kasus Khusus: HTTP 409 Conflict (Warning Butuh Konfirmasi)
Jika job saat ini sedang berstatus `'Proses'` (terapis lama sedang memijat/menjalankan treatment), backend mengembalikan **HTTP 409 Conflict**:
```json
{
  "status": false,
  "message": "Terapis dewi.sartika saat ini sedang MEMPROSES treatment ini. Apakah Anda yakin ingin memindahkan job ke siti.nurhaliza?",
  "data": {
    "status": "warning",
    "need_confirmation": true,
    "message": "Terapis dewi.sartika saat ini sedang MEMPROSES treatment ini...",
    "current_terapis": "dewi.sartika",
    "new_terapis": "siti.nurhaliza",
    "rowid": 128
  }
}
```
**Frontend Handling:**
Tampilkan modal dialog peringatan:
> *"Terapis dewi.sartika saat ini sedang MEMPROSES treatment ini. Apakah Anda yakin ingin memindahkan job ke siti.nurhaliza?"*
- Jika pengguna memilih **Batal**: Tutup modal.
- Jika pengguna memilih **Tetap Pindahkan**: Kirim ulang request dengan parameter `"force": true`.

---

### Endpoint 10: `GET /report.php` (Laporan & Komisi Terapis)
- **Alias Endpoint:** `GET /get_terapis_report.php`
- **Tujuan:** Mengambil ringkasan komisi 5%, riwayat pengerjaan treatment, dan rincian komisi override paket.
- **Auth:** Wajib Bearer Token.
- **Tipe Laporan via Query Parameter `?type=...`:**
  1. `?type=summary` (Default): Ringkasan komisi reguler 5%, komisi override 5%, total komisi, dan rincian omzet.
  2. `?type=pengerjaan`: Rincian seluruh pengerjaan treatment (Normal, Redeem, Redeem Override, Paket Lama).
  3. `?type=override`: Rincian komisi sharing paket (Override Masuk $+$ & Override Keluar $-$).
  4. `?type=all`: Menggabungkan summary, pengerjaan, dan override dalam 1 response.
- **Query Filter:** `?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&kode_gerai=JKS01` *(Default: Tanggal 1 s.d akhir bulan berjalan).*

#### Response Sukses (HTTP 200) - `?type=summary`
```json
{
  "status": true,
  "message": "Summary komisi terapis berhasil diambil",
  "data": {
    "terapis": "siti.nurhaliza",
    "periode": {
      "start_date": "2026-10-01",
      "end_date": "2026-10-31",
      "kode_gerai": null
    },
    "komisi_reguler_5_persen": 425000.0,
    "komisi_redeem_5_persen": 50000.0,
    "total_komisi_5_persen": 475000.0,
    "omzet": {
      "treatment_sebelum_diskon": 7000000.0,
      "treatment_setelah_diskon": 6500000.0,
      "paket_sebelum_diskon": 2000000.0,
      "paket_setelah_diskon": 2000000.0,
      "pendapatan_redeem": 1000000.0,
      "total_sebelum_diskon": 9000000.0,
      "total_setelah_diskon": 8500000.0
    },
    "pengerjaan_stats": {
      "total_qty": 28,
      "total_nominal": 7500000.0,
      "total_items": 28
    },
    "override_stats": {
      "total_override_masuk": 75000.0,
      "total_override_keluar": 25000.0,
      "total_override_items": 4
    }
  }
}
```

#### Dedicated Sub-Endpoints (Alias Khusus):
- `GET /komisi_summary.php`: Langsung merespons data `summary`.
- `GET /pengerjaan.php`: Langsung merespons data `pengerjaan`.
- `GET /komisi_override.php`: Langsung merespons data `override`.

#### Error States & Frontend Handling
| HTTP Status | Kondisi Penyebab | Response JSON Backend | Rekomendasi Handling Frontend |
|---|---|---|---|
| **401 Unauthorized** | Token hilang / kadaluarsa. | `{"status": false, "message": "Unauthorized: Token tidak valid atau telah kadaluarsa", "data": null}` | Redirect ke Login. |
| **403 Forbidden** | Akun dinonaktifkan. | `{"status": false, "message": "Forbidden: Akun Anda telah dinonaktifkan", "data": null}` | Logout paksa. |
| **405 Method Not Allowed** | Request dikirim bukan dengan method `GET`. | `{"status": false, "message": "Metode request tidak diizinkan. Gunakan GET.", "data": null}` | Gunakan method `GET`. |

---

## 4. Master Matriks Seluruh Error State API Terapis v4

Tabel berikut merangkum seluruh kemungkinan pesan error pada seluruh endpoint `api_terapis_v4`:

| Endpoint / Layanan | HTTP | Pesan Error Backend (`message`) | Kategori Masalah | Aksi Frontend |
|---|---|---|---|---|
| **Global (Semua)** | `401` | `Unauthorized: Token tidak valid atau telah kadaluarsa` | Auth Token | Hapus token lokal & redirect ke Login |
| **Global (Semua)** | `401` | `Unauthorized: Pengguna tidak ditemukan` | Auth User | Hapus session & redirect ke Login |
| **Global (Semua)** | `403` | `Forbidden: Akun Anda telah dinonaktifkan` | Akun Diblokir | Dialog alert "Akun dinonaktifkan" & logout |
| **Global (Semua)** | `403` | `Forbidden: Hak akses bukan terapis` | Otorisasi Role | Logout & alert akses ditolak |
| **Global (Semua)** | `500` | `Gagal terhubung ke database: ...` | Server MySQL | Toast / Banner kendala server & retry |
| `POST /login.php` | `405` | `Metode request tidak diizinkan. Gunakan POST.` | HTTP Method | Gunakan method POST |
| `POST /login.php` | `422` | `Username dan password wajib diisi` | Validasi Form | Tampilkan helper text di input form |
| `POST /login.php` | `401` | `Username atau password salah` | Kredensial Salah | Tampilkan snackbar merah & kosongkan password |
| `POST /login.php` | `403` | `Akun Anda tidak aktif atau diblokir. Silakan hubungi admin.` | Blokir Akun | Tampilkan modal bantuan kontak admin |
| `POST /me.php` | `422` | `Tidak ada data yang dikirim untuk diupdate` | Form Kosong | Disable tombol simpan bila tak ada perubahan |
| `POST /me.php` | `422` | `Format email tidak valid` | Format Email | Inline error text pada input email |
| `POST /me.php` | `422` | `Password baru minimal 6 karakter` | Validasi Password | Inline error text pada password baru |
| `POST /me.php` | `400` | `Password lama tidak sesuai` | Kredensial Password | Inline error text pada password lama |
| `POST /me.php` | `404` | `Pengguna tidak ditemukan` | User Terhapus | Logout paksa |
| `GET /gerai.php` | `400` | `Parameter 'id_gerai' wajib diisi jika tidak menyertakan token...` | Parameter Kurang | Sertakan token Bearer atau parameter URL |
| `GET /gerai.php` | `404` | `Data gerai tidak ditemukan atau sedang dinonaktifkan.` | Data Kosong | Sembunyikan tombol WA / info gerai |
| `POST /absensi.php` | `422` | `Parameter 'action' wajib diisi ('check_in' atau 'check_out').` | Validasi Action | Kirim action yang benar |
| `POST /absensi.php` | `400` | `Action tidak valid. Gunakan 'check_in' atau 'check_out'.` | Validasi Enum | Gunakan 'check_in' atau 'check_out' |
| `POST /absensi.php` | `400` | `Anda sudah On Duty. Harap Check-Out terlebih dahulu.` | Status Absensi | Disable Check-In button; refresh state |
| `POST /absensi.php` | `400` | `Anda sedang Off Duty. Harap Check-In terlebih dahulu.` | Status Absensi | Disable Check-Out button; refresh state |
| `GET /jobs.php` | `404` | `Job tidak ditemukan atau Anda tidak memiliki akses ke job ini.` | Hak Milik Job | Dialog "Job dialihkan", refresh daftar job |
| `POST /jobs.php` | `400` | `Parameter action wajib diisi.` | Parameter Kurang | Kirim parameter action |
| `POST /jobs.php` | `400` | `Parameter id_job_status atau job_id wajib diisi.` | Parameter Kurang | Kirim ID job yang dikerjakan |
| `POST /jobs.php` | `400` | `Action '<action>' tidak dikenal.` | Action Tidak Sah | Gunakan action standar yang didukung |
| `POST /jobs.php` | `400` | `Job tidak ditemukan atau bukan milik Anda.` | Hak Milik Job | Refresh daftar job |
| `POST /jobs.php` (arrived) | `400` | `Status Arrived hanya berlaku untuk layanan Homecare.` | Kategori Layanan | Sembunyikan tombol Arrived untuk onsite |
| `POST /jobs.php` (arrived) | `400` | `Job saat ini berstatus '<status>', tidak dapat diset Arrived.` | Transisi Status | Sinkronkan state tombol aksi |
| `POST /jobs.php` (start) | `400` | `Treatment sudah dalam proses berjalan.` | Status Berjalan | Update UI ke mode Proses & aktifkan timer |
| `POST /jobs.php` (start) | `400` | `Treatment sudah selesai.` | Status Selesai | Kunci UI pengerjaan |
| `POST /jobs.php` (pause) | `400` | `Hanya treatment yang sedang berjalan (Proses) yang dapat di-pause.` | Status Bukan Proses | Disable tombol Pause |
| `POST /jobs.php` (pause) | `400` | `Timer saat ini sudah dalam keadaan pause.` | Status Timer | Ubah tombol ke Resume |
| `POST /jobs.php` (resume) | `400` | `Treatment tidak sedang dalam proses.` | Status Bukan Proses | Disable tombol Resume |
| `POST /jobs.php` (resume) | `400` | `Timer tidak sedang di-pause.` | Status Timer | Ubah tombol ke Pause |
| `POST /jobs.php` (complete)| `400` | `Job ini sudah berstatus Selesai.` | Status Selesai | Hentikan timer & arahkan ke List Job |
| `POST /jobs.php` (reassign)| `409` | `Terapis <old> saat ini sedang MEMPROSES treatment ini...` | Warning Konflik | Tampilkan modal konfirmasi "force: true" |
| `POST /jobs.php` (reassign)| `400` | `Nama terapis tujuan tidak valid.` | Parameter Salah | Pilih terapis yang valid |
| `POST /jobs.php` (reassign)| `400` | `Item transaksi_detail rowid <rowid> tidak ditemukan.` | Data Kosong | Periksa rowid item |

---

## 5. Fitur Tambahan & Background Automation

### 5.1. Background Cron Auto-Checkout
- **File Script:** `cron_auto_checkout.php`
- **Jadwal Eksekusi Server:** Setiap hari jam 00:01 WIB (Tengah Malam).
- **Perilaku Sistem:**
  Menyapu seluruh terapis yang status terakhirnya masih `check_in` di hari sebelumnya. Sistem secara otomatis membuat record `check_out` pada `23:59:59` hari tersebut dengan catatan:
  `'Lupa Offduty (Human Error)'`.
- **Dampak pada Frontend:** Terapis yang membuka aplikasi di hari baru secara otomatis berstatus **Off Duty** dengan tombol **Check In** siap ditekan tanpa perlu intervensi manual.

### 5.2. Dukungan Transaksi Status `Closed`
- Transaksi nota yang sudah diselesaikan pembayarannya di kasir web akan berstatus `Closed`.
- **Penting bagi Frontend Mobile:** Status nota `Closed` tidak mematikan atau mengunci job terapis di aplikasi mobile. Terapis tetap dapat menyelesaikan tahapan treatment dan menekan tombol **Selesai (Complete)** secara normal.
