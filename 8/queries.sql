
/* 
 * Создайте таблицу logs типа Archive. 
 * Пусть при каждом создании записи в таблицах users, catalogs и products 
 * в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
 */

DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs` (
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	`tbl` VARCHAR(15) NOT NULL,
	`id` INT UNSIGNED NOT NULL,
	`name` VARCHAR(255)
) ENGINE=ARCHIVE;

DROP TRIGGER IF EXISTS `log_new_users`;
DELIMITER //
CREATE TRIGGER `log_new_users` AFTER INSERT ON `users`
FOR EACH ROW
BEGIN
	INSERT INTO `logs` (`tbl`, `id`, `name`) VALUES ('users', NEW.id, NEW.name);
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `log_new_products`;
DELIMITER //
CREATE TRIGGER `log_new_products` AFTER INSERT ON `products`
FOR EACH ROW
BEGIN
	INSERT INTO `logs` (`tbl`, `id`, `name`) VALUES ('products', NEW.id, NEW.name);
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `log_new_catalogs`;
DELIMITER //
CREATE TRIGGER `log_new_catalogs` AFTER INSERT ON `catalogs`
FOR EACH ROW
BEGIN
	INSERT INTO `logs` (`tbl`, `id`, `name`) VALUES ('catalogs', NEW.id, NEW.name);
END//
DELIMITER ;


/* 
 * Создайте SQL-запрос, который помещает в таблицу users миллион записей.
 */
DROP PROCEDURE IF EXISTS `create_random_users`;
DELIMITER //
CREATE PROCEDURE `create_random_users` (IN users_count INT UNSIGNED)
BEGIN
	DECLARE MIN_BIRTH_DATE DATE DEFAULT '1970-01-01';
	DECLARE MAX_BIRTH_DATE DATE DEFAULT '2005-01-01';
	
	DECLARE birthday_at DATE DEFAULT '1970-01-01';
	DECLARE user_name VARCHAR(30) DEFAULT "User";
	DECLARE i INT DEFAULT 0;
	lp: LOOP
    	SET i = i + 1;
    	IF i > users_count THEN
    		LEAVE lp;
    	END IF;
    	SET birthday_at = TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, MIN_BIRTH_DATE, MAX_BIRTH_DATE)), MIN_BIRTH_DATE);
    	SET user_name = CONCAT("User ", i); 
    	INSERT INTO `users` (`birthday_at`, `name`) VALUES (birthday_at, user_name);
	END LOOP lp;
END//

CALL create_random_users(1000000);









