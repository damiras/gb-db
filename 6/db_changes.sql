/*
 * Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине. 
 */

INSERT INTO orders (user_id) VALUES (1), (3), (3), (3), (5), (5), (5), (5), (5); 

SELECT DISTINCT o.user_id, u.name FROM orders o JOIN users u ON o.user_id = u.id;

/* 
 * Выведите список товаров products и разделов catalogs, который соответствует товару.
 */

SELECT p.id, p.name, p.price, c.name AS `catalog` FROM products p LEFT JOIN catalogs c ON p.catalog_id = c.id;


/*
 * Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, поле name — русское. 
 * Выведите список рейсов flights с русскими названиями городов.
 */

CREATE TABLE cities (
	label VARCHAR(60) NOT NULL PRIMARY KEY,
	name VARCHAR(60) NOT NULL
);

CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	`from` VARCHAR(60) NOT NULL,
	`to` VARCHAR(60) NOT NULL,
	CONSTRAINT fk_from FOREIGN KEY (`from`) REFERENCES cities (label),
	CONSTRAINT fk_to FOREIGN KEY (`to`) REFERENCES cities (label)
);

INSERT INTO cities VALUES 
('moscow', 'Москва'),
('irkutsk', 'Иркутск'),
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');

INSERT INTO flights (`from`, `to`) VALUES 
('moscow', 'omsk'),
('novgorod', 'kazan'),
('irkutsk', 'moscow'),
('omsk', 'irkutsk'),
('moscow', 'kazan');

SELECT f.id, c1.name AS `from`, c2.name AS `to` 
FROM flights f 
JOIN cities c1 ON f.`from` = c1.label 
JOIN cities c2 ON f.`to` = c2.label;
