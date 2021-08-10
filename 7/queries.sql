/*
 * В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
 * Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
 */

START TRANSACTION;
INSERT INTO sample.users (name, birthday_at, created_at, updated_at) 
	SELECT name, birthday_at, created_at, updated_at FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
COMMIT;

/*
 * Создайте представление, которое выводит название name товарной позиции из таблицы products 
 * и соответствующее название каталога name из таблицы catalogs.
 */

DROP VIEW IF EXISTS `goods_view`;
CREATE VIEW `goods_view` AS
	SELECT p.name, c.name AS `catalog` FROM products p LEFT JOIN catalogs c ON p.catalog_id = c.id;
SELECT * FROM `goods_view`;


/*
 * Пусть имеется таблица с календарным полем created_at. 
 * В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
 * Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
 * если дата присутствует в исходном таблице и 0, если она отсутствует.
 */

CREATE TABLE sample.august_dates (
	id SERIAL PRIMARY KEY,
	created_at DATE
);

INSERT INTO sample.august_dates (created_at) VALUES
('2018-08-01'), ('2016-08-04'), ('2018-08-16'), ('2018-08-17')

DROP VIEW IF EXISTS sample.all_august_days;
CREATE VIEW sample.all_august_days AS
SELECT DATE_ADD('2018-08-01', INTERVAL august_days.m - 1 DAY) AS created_at FROM
(
	SELECT 1 AS m UNION SELECT 2 AS m UNION SELECT 3 AS m UNION SELECT 4 AS m UNION SELECT 5 AS m UNION SELECT 6 AS m UNION SELECT 7 AS m UNION SELECT 8 AS m
	UNION SELECT 9 AS m UNION SELECT 10 AS m UNION SELECT 11 AS m UNION SELECT 12 AS m UNION SELECT 13 AS m UNION SELECT 14 AS m UNION SELECT 15 AS m UNION SELECT 16 AS m
	UNION SELECT 17 AS m UNION SELECT 18 AS m UNION SELECT 19 AS m UNION SELECT 20 AS m UNION SELECT 21 AS m UNION SELECT 22 AS m UNION SELECT 23 AS m UNION SELECT 24 AS m
	UNION SELECT 25 AS m UNION SELECT 26 AS m UNION SELECT 27 AS m UNION SELECT 28 AS m UNION SELECT 29 AS m UNION SELECT 30 AS m UNION SELECT 31 AS m
) AS august_days;


SELECT aad.created_at, IF(ad.created_at IS NULL, 0, 1) AS month_exists 
FROM sample.all_august_days aad LEFT JOIN sample.august_dates ad USING(created_at)
ORDER BY aad.created_at;


/*
 * Пусть имеется любая таблица с календарным полем created_at. 
 * Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
 */

TRUNCATE sample.august_dates;
INSERT INTO sample.august_dates (created_at) SELECT created_at FROM sample.all_august_days;

DROP VIEW IF EXISTS sample.fresh_five_rows;
CREATE VIEW sample.fresh_five_rows AS 
SELECT id FROM sample.august_dates ORDER BY created_at DESC LIMIT 5;

DELETE FROM sample.august_dates WHERE id NOT IN ( SELECT * FROM sample.fresh_five_rows );



/*
 * Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 * с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 * с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */

DROP FUNCTION IF EXISTS hello;

delimiter //
CREATE FUNCTION hello() RETURNS varchar(15)
BEGIN
	DECLARE now_time TIME DEFAULT NOW();
	IF now_time >= '6:00' AND now_time < '12:00' THEN 
		RETURN "Доброе утро!";
	ELSEIF now_time >= '12:00' AND now_time < '18:00' THEN
		RETURN "Добрый день!";
	ELSE
		RETURN "Доброй ночи!";
	END IF;
END//
delimiter ;

SELECT hello();


/*
 * В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
 * Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
 */

DROP TRIGGER IF EXISTS check_product_name_before_update;

DELIMITER //
CREATE TRIGGER `check_product_name_before_update` BEFORE UPDATE ON `products` 
	FOR EACH ROW 
	BEGIN
		IF (NEW.name IS NULL OR NEW.name = '') AND (NEW.description IS NULL OR NEW.description = '') THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'name or description must be filled in';
		END IF;
    END//
DELIMITER ;

DROP TRIGGER IF EXISTS check_product_name_before_insert;

DELIMITER //
CREATE TRIGGER `check_product_name_before_insert` BEFORE INSERT ON `products` 
	FOR EACH ROW 
	BEGIN
		IF (NEW.name IS NULL OR NEW.name = '') AND (NEW.description IS NULL OR NEW.description = '') THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'name or description must be filled in';
		END IF;
    END//
DELIMITER ;


/*
 * Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
 * Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
 * Вызов функции FIBONACCI(10) должен возвращать число 55.
 */

DROP FUNCTION IF EXISTS fibonacci;

delimiter //
CREATE FUNCTION fibonacci(n INT UNSIGNED) RETURNS INT UNSIGNED
BEGIN
	DECLARE p1 FLOAT;
	DECLARE p2 FLOAT;
	DECLARE d FLOAT;
	SET d = SQRT(5);
	SET p1 = (1 + d) / 2;
	SET p2 = (1 - d) / 2;
	RETURN (POW(p1, n) - POW(p2, n)) / d;
END//
delimiter ;

SELECT fibonacci(10);


/*
 * Создайте двух пользователей которые имеют доступ к базе данных shop. 
 * Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
 * второму пользователю shop — любые операции в пределах базы данных shop. 
 */

CREATE USER IF NOT EXISTS 'shop_read'@'localhost' IDENTIFIED BY 'pass';
CREATE USER IF NOT EXISTS 'shop'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON shop.* TO 'shop'@'localhost';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';
FLUSH PRIVILEGES;

/*
 * Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
 * Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
 * Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
 */

USE sample;
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
	`id` SERIAL PRIMARY KEY,
	`name` VARCHAR(100),
	`password` VARCHAR(255)
);

INSERT INTO `accounts` (`name`, `password`) VALUES 
('John', 'pass'), ('Smith', 'password'), ('Mark', 'qwerty');

DROP VIEW IF EXISTS `username`;
CREATE VIEW `username` AS 
SELECT id, name FROM accounts;

CREATE USER IF NOT EXISTS 'user_read'@'localhost' IDENTIFIED BY 'pass';
GRANT SELECT ON sample.username TO 'user_read'@'localhost';










































































