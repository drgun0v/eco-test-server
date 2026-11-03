-- Skema Database untuk Alamat Tersimpan (Saved Places) EcoCab
CREATE TABLE IF NOT EXISTS `eco_taxi_saved_places` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(64) NOT NULL,
  `label` VARCHAR(60) NOT NULL,
  `tag` VARCHAR(25) DEFAULT 'Favorit',
  `coords` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel Rekap Rating Driver & Layanan EcoCab
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

-- Tabel Paket Langganan EcoVIP (Masa aktif 10 Hari & 30x Voucher Trip)
CREATE TABLE IF NOT EXISTS `eco_taxi_vip` (
  `identifier` VARCHAR(64) PRIMARY KEY,
  `is_active` TINYINT(1) DEFAULT 1,
  `remaining_trips` INT DEFAULT 30,
  `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NULL,
  INDEX (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel Riwayat Perjalanan (Trip History)
CREATE TABLE IF NOT EXISTS `eco_taxi_trips` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(64) NOT NULL,
  `service_type` VARCHAR(25) NOT NULL,
  `origin_name` VARCHAR(80) DEFAULT 'Lokasi Penjemputan',
  `dest_name` VARCHAR(80) NOT NULL,
  `distance_km` DECIMAL(5,2) NOT NULL,
  `base_fare` INT NOT NULL,
  `final_fare` INT NOT NULL,
  `discount_applied` INT DEFAULT 0,
  `surge_multiplier` DECIMAL(3,2) DEFAULT 1.00,
  `driver_name` VARCHAR(80) NOT NULL,
  `rating` INT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
