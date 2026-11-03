# Panduan Instalasi `eco_tablet` (v2.0.0 - EcoLink Transit & Uber-Style EcoCab)

Pembaruan besar ini membawa desain antarmuka modern iPadOS dengan integrasi penuh:
1. **EcoLink Transit System**:
   - 4 Menu Sidebar: **Halte**, **Stasiun**, **Kereta (Aktif)**, dan **Bus (Aktif)**.
   - Ikon bus bersudut tumpul (*rounded rect*) & ikon kereta lingkaran penuh (*circle*).
   - **Diagram Jalur Vertikal** dengan rel berwarna dan indikator lingkaran terisi saat armada sedang berhenti di peron/halte.
2. **EcoCab Smart Taxi App (Uber-Style UI)**:
   - **3 Kelas Layanan**:
     * **EcoLuxe**: Sedan EV otonom `vivanite2` (limit 120 km/j, buka pintu $30, $18/km, min $50, driverless AI).
     * **EcoCab**: Taksi standar `taxi` (limit 80 km/j, buka pintu $25, $14/km, min $30).
     * **EcoRide**: Ojek motor `faggio` (limit 60 km/j, buka pintu $0, $8/km, min $15).
   - **Pilihan Destinasi Fleksibel**:
     * 10 Destinasi Cepat Populer Los Santos.
     * Ambil titik dari **Waypoint Peta GPS** GTA V (`Pause Map`).
     * **Simpan Alamat Favorit (Database `oxmysql`)**: Tersimpan secara privat per-karakter.
   - **Tampilan Real-Time "Driver is on the way"**:
     * Nama pengemudi acak dari 50 nama orang Indonesia (kecuali EcoLuxe yang berlabel AI Driverless).
     * Perhitungan langsung ETA menit dan sisa jarak kilometer.
     * Indikator peringatan jika driver EcoRide mampir isi bensin di SPBU.
   - **Modal Rating Pasca-Trip (1-5 Bintang & Tip)**:
     * Penilaian driver dan opsi memberi uang tip ($2, $5, $10) yang langsung tersimpan ke database.

## 1. Import Skema Database SQL
Jalankan file `schema.sql` pada database server Anda melalui HeidiSQL atau phpMyAdmin:
```sql
CREATE TABLE IF NOT EXISTS `eco_taxi_saved_places` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(64) NOT NULL,
  `label` VARCHAR(60) NOT NULL,
  `tag` VARCHAR(25) DEFAULT 'Favorit',
  `coords` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `eco_taxi_ratings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(64) NOT NULL,
  `service_type` VARCHAR(25) NOT NULL,
  `driver_name` VARCHAR(80) NOT NULL,
  `rating` INT NOT NULL,
  `tip` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 2. Penempatan Folder Resource
Salin folder `eco_tablet` ke dalam direktori:
`resources/[standalone]/eco_tablet`

## 3. Pastikan Urutan di `server.cfg`
```cfg
ensure oxmysql
ensure es_extended
ensure eco_bus
ensure eco_subway
ensure eco_taxi
ensure eco_tablet
```

## 4. Cara Membuka di Game
- **Command**: Ketik `/tablet`, `/ecolink`, atau `/ecocab` di chat atau konsol F8.
- **Tombol Pintas**: Tekan tombol **`F4`**.
