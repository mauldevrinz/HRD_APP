# Admin Account Credentials

## Default Admin Account

Akun admin akan otomatis dibuat saat aplikasi pertama kali dijalankan.

### Credentials:
```
Email    : admin@gmail.com
Password : admin123
```

### Informasi Admin:
- **Nama**: Administrator
- **Role**: admin
- **Department**: IT
- **Employee ID**: ADMIN001

## Cara Login sebagai Admin:

1. Buka aplikasi
2. Tunggu splash screen selesai (admin account akan dibuat otomatis)
3. Login dengan credentials di atas
4. Setelah login, buka halaman **Account** (tab paling kanan)
5. Button **"Dashboard Admin"** akan muncul jika login sebagai admin
6. Klik button tersebut untuk mengakses Admin Dashboard

## Cara Membuat Admin Tambahan:

### Opsi 1: Via Code (SetAdminHelper)
```dart
// Set user tertentu sebagai admin berdasarkan email
await SetAdminHelper.setUserAsAdmin('user@example.com');

// Atau set current logged in user sebagai admin
await SetAdminHelper.setCurrentUserAsAdmin();
```

### Opsi 2: Manual via Firestore
1. Buka Firebase Console
2. Masuk ke Firestore Database
3. Cari collection `users`
4. Pilih dokumen user yang ingin dijadikan admin
5. Edit field `role` menjadi `'admin'`

## Fitur Admin Dashboard:

- View semua users
- Statistik & KPI
- Manage permissions
- View reports dari semua users
- Analytics

## Catatan Keamanan:

⚠️ **PENTING**: 
- Ganti password default setelah login pertama kali
- Jangan share credentials admin ke sembarang orang
- Untuk production, implementasikan password yang lebih kuat
- Pertimbangkan menambahkan 2FA (Two-Factor Authentication)

## Troubleshooting:

**Q: Admin account tidak bisa login?**
- Pastikan Firebase sudah ter-setup dengan benar
- Check koneksi internet
- Check Firebase Console apakah user ada di Authentication

**Q: Button "Dashboard Admin" tidak muncul?**
- Pastikan sudah login dengan akun admin@gmail.com
- Check Firestore apakah field `role` = `'admin'`
- Restart aplikasi

**Q: Lupa password admin?**
- Gunakan fitur "Lupa Password" di halaman login
- Atau reset via Firebase Console > Authentication

---

Created: 2 November 2024
Last Updated: 2 November 2024
