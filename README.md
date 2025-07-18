# 💼 ContractRec - HR Business Intelligence System

Sistem rekomendasi perpanjangan kontrak karyawan berbasis React.js & PHP. Menggunakan analitik berbasis data untuk menyarankan keputusan kontrak yang cerdas, personal, dan adaptif.

---

## ⚙️ Teknologi

- **Frontend**: React.js + Bootstrap 5
- **Backend**: PHP + MySQL
- **Analitik**: Python (`employee_contract_analysis.py`)
- **Dev Tools**: XAMPP, Node.js, npm

---

## 🚀 Fitur Utama

- 📊 **Dashboard Interaktif**: Statistik karyawan dan performa kontrak  
- 🤖 **Sistem Rekomendasi Dinamis**: Berdasarkan pendidikan, role, masa kerja, dan tren resign  
- 👥 **Manajemen Karyawan**: Input, edit, dan tracking riwayat kontrak  
- 🔐 **Role-Based Access**: Admin, HR, Manager  
- 📈 **Analytics Lengkap**: Per divisi, kontrak, pendidikan, dan pola resign

---

## 🛠️ Cara Instalasi Cepat

### 1. Setup Database (XAMPP + phpMyAdmin)

- Jalankan XAMPP: Start **Apache** dan **MySQL**
- Buka browser: `http://localhost/phpmyadmin`
- Buat database baru bernama: `contract_rec_db`
- Import file `db/contract_rec_db.sql`

### 2. Jalankan Backend

- Pindahkan folder `backend/` ke dalam folder `htdocs/` milik XAMPP:
  - Windows: `C:\xampp\htdocs\web_srk_BI\backend\`
  - macOS/Linux: `/Applications/XAMPP/htdocs/web_srk_BI/backend/`
- Tes API endpoint:  
  Buka `http://localhost/web_srk_BI/backend/api/auth.php`  
  Harus muncul response JSON

### 3. Jalankan Frontend

```bash```
cd frontend
npm install
npm start

Akses frontend di browser: http://localhost:3000
Login default:  
Username: admin  
Password: password  

## 🔍 Sistem Rekomendasi (Logika Inti)

Sistem menggunakan _rule-based analysis_ dari file `employee_contract_analysis.py`, tanpa machine learning. Rekomendasi dibuat berdasarkan:

- 📌 **Education vs Role**  
  Jika jurusan ≠ role → sistem memberikan durasi kontrak pendek.  
  Jika jurusan = role + pendidikan minimal S1 → durasi optimal (hingga 12 bulan).

- ⏳ **Lama Kontrak & Performa**  
  Semakin banyak kontrak sukses → sistem menyarankan status **Permanent**.

- 📈 **Tren Resign**  
  Jika tingkat resign tinggi pada kontrak tertentu → sistem tidak merekomendasikannya.

### 💡 Contoh Output Rekomendasi

- `Henry (S1 Informatika, Data Dev, Kontrak 3)` → **Siap Permanent**
- `Nicholas (S1 Kedokteran, Fullstack, Kontrak 2)` → **Rekomendasi Kontrak 2 (12 bulan)**

---

## 🔐 Keamanan

- ✅ **Session-based Authentication**
- ✅ **Role-based Access Control** (Admin, HR, Manager)
- ✅ **SQL Injection Prevention** dengan prepared statements
- ✅ **XSS Protection** dan validasi input
- ✅ **CSRF Protection** pada setiap form

---

## 📅 Roadmap

### ✅ v1.0 (Release saat ini)
- Sistem login & autentikasi
- CRUD data karyawan & kontrak
- Engine rekomendasi berbasis aturan
- Dashboard interaktif & analitik
- Hak akses role: Admin, HR, Manager
- Responsive UI

### 🔜 v1.1 (Planned)
- Export data ke PDF/Excel
- Notifikasi email otomatis
- Bulk operation untuk data kontrak
- Advanced filter & pencarian
- Dokumentasi API publik

---

**Selamat datang di ContractRec!**  
Gunakan sistem ini untuk membantu pengambilan keputusan kontrak karyawan yang lebih cerdas, konsisten, dan berbasis data nyata.
