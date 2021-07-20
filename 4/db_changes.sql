SET NAMES utf8;
SET CHARSET utf8;

/* Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
 * Заполните их текущими датой и временем. */
UPDATE users SET created_at = NOW(), updated_at = NOW();

/* Таблица users была неудачно спроектирована. 
 * Записи created_at и updated_at были заданы типом VARCHAR 
 * и в них долгое время помещались значения в формате 20.10.2017 8:10. 
 * Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения. */
-- Для начал создадим эти колонки и заполним их случайными данными.
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users DROP COLUMN updated_at;
ALTER TABLE users ADD COLUMN created_at VARCHAR(16);
ALTER TABLE users ADD COLUMN updated_at VARCHAR(16);
UPDATE users SET 
created_at = DATE_FORMAT(FROM_UNIXTIME(ROUND(1500000000 + 127000000 * SQRT(RAND() / `id`))), "%d.%m.%Y %k:%i"),
updated_at = DATE_FORMAT(DATE_ADD(FROM_UNIXTIME(ROUND(1500000000 + 127000000 * SQRT(RAND() / `id`))), INTERVAL `id` HOUR), "%d.%m.%Y %k:%i");
-- Теперь преобразуем данные
ALTER TABLE users MODIFY created_at VARCHAR(20);
ALTER TABLE users MODIFY updated_at VARCHAR(20);
UPDATE users SET created_at = STR_TO_DATE(created_at, "%d.%m.%Y %k:%i");
UPDATE users SET updated_at = STR_TO_DATE(updated_at, "%d.%m.%Y %k:%i");
ALTER TABLE users MODIFY created_at DATETIME;
ALTER TABLE users MODIFY updated_at DATETIME;


/* В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
 * 0, если товар закончился и выше нуля, если на складе имеются запасы. 
 * Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
 * Однако нулевые запасы должны выводиться в конце, после всех */
-- Заполняем данными
INSERT INTO storehouses VALUES (DEFAULT, 'Storehouse 1', DEFAULT, DEFAULT);
INSERT INTO storehouses VALUES (DEFAULT, 'Storehouse 2', DEFAULT, DEFAULT);
INSERT INTO storehouses VALUES (DEFAULT, 'Storehouse 3', DEFAULT, DEFAULT);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 1, 1);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 2, 3);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 3, 0);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 4, 2);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 5, 4);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 6, 5);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (1, 7, 6);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 1, 0);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 2, 2);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 3, 1);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 4, 3);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 5, 4);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 6, 5);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (2, 7, 6);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 1, 2);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 2, 1);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 3, 3);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 4, 5);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 5, 0);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 6, 0);
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES (3, 7, 9);
-- Сам запрос 
SELECT * FROM storehouses_products ORDER BY value = 0, value;

/*  Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
 * Месяцы заданы в виде списка английских названий (may, august) */
SELECT id, name, SUBSTR(birthday_at, 6, 2) AS birth_month_number,
CASE
    WHEN SUBSTR(birthday_at, 6, 2) = '05' 
        THEN 'may'
    WHEN SUBSTR(birthday_at, 6, 2) = '08' 
        THEN 'august'
    ELSE 'other month'
END AS birth_month
FROM users
HAVING birth_month IN('may', 'august');

/* Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
 * Отсортируйте записи в порядке, заданном в списке IN. */
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY 
CASE
	WHEN id = 5 THEN 0
	WHEN id = 1 THEN 1
	WHEN id = 2 THEN 2
END;

/* Подсчитайте средний возраст пользователей в таблице users */
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, CURDATE())) AS ave_age FROM users;

/* Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
 * Следует учесть, что необходимы дни недели текущего года, а не года рождения. */
SELECT id, name, birthday_at, 
CASE
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 0 THEN 'Mon'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 1 THEN 'Tue'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 2 THEN 'Wed'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 3 THEN 'Thu'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 4 THEN 'Fri'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 5 THEN 'Sat'
	WHEN WEEKDAY(CONCAT(YEAR(CURDATE()), SUBSTR(birthday_at, 5))) = 6 THEN 'Sun'
END AS birth_day
FROM users; 

/* Подсчитайте произведение чисел в столбце таблицы */
SELECT EXP(SUM(LN(id))) AS mult FROM users; -- ln(x1) + ln(x2) + ... + ln(xn) = ln(x1 * x2 * ... * xn); exp(ln(x)) = e ^ ln(x) = x




















