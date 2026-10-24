CREATE TABLE `restaurants_recipes` (
	`id` INT(10) NOT NULL AUTO_INCREMENT,
	`label` VARCHAR(50) NULL DEFAULT NULL,
	`description` VARCHAR(50) NULL DEFAULT NULL,
	`image_url` VARCHAR(100) NULL DEFAULT NULL,
	`ingredients` LONGTEXT NULL DEFAULT NULL,
	`animation` VARCHAR(50) NULL DEFAULT NULL,
	`type` VARCHAR(50) NULL DEFAULT NULL,
	`stations` LONGTEXT NULL DEFAULT NULL,
	`active` INT(10) NULL DEFAULT NULL,
	`price` INT(10) NULL DEFAULT NULL,
	`job` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
);

CREATE TABLE `restaurants_menus` (
	`id` INT(10) NOT NULL AUTO_INCREMENT,
	`image_url` VARCHAR(100) NULL DEFAULT NULL,
	`job` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
);

CREATE TABLE IF NOT EXISTS `restaurants_employee_stats` (
  `identifier` varchar(50) NOT NULL,
  `job` varchar(50) NOT NULL,
  `sales_count` int(11) DEFAULT 0,
  `total_earnings` int(11) DEFAULT 0,
  PRIMARY KEY (`identifier`, `job`)
);