CREATE TABLE IF NOT EXISTS `eco_foursummit_hof` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `character_name` VARCHAR(120) NOT NULL,
    `passport_serial` VARCHAR(32) NOT NULL,
    `josiah_date` VARCHAR(32) DEFAULT NULL,
    `chiliad_date` VARCHAR(32) DEFAULT NULL,
    `gordo_date` VARCHAR(32) DEFAULT NULL,
    `chianski_date` VARCHAR(32) DEFAULT NULL,
    `completed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_conqueror` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
