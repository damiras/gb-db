DROP DATABASE IF EXISTS vk;

CREATE DATABASE vk;

-- используем БД vk
USE vk;

-- показываем все таблицы
SHOW tables;

/*
 * 1. Создадим таблицу users.
*/

/*
 * Таблица с пользователями.
 * 
 * Сценарий: Необходимо хранить данные зарегестрированных пользователей.
 * 
 * Что есть у пользователей: айди - уникальный идентификатор пользователя,
 * имя, фамилия, телефон, почта.
 * 
 * Так как у нас есть айди - он становится primary key. У каждой хорошо построенной таблицы
 * должен быть primary key. Он ускоряет поиск по значению и гарантирует, что все значения в колонке
 * уникальны.
 * Также айди автоматически инкрементируется, будет принимать значения (1,2,3,...)
 * 
 * Хотим, чтобы пользователь при регистрации обязательно заполнял все эти данные.
 * Тогда добавляем к определению колонки NOT NULL.
 * 
 * Хотим также хранить пароль (хэш-пароля), и чтобы у пользователя была возможность не задавать 
 * пароль при регистрации.
 * Добавляем к определению колонки password_hash DEFAULT NULL.
 * 
 * Хотим также хранить дату и время регистрации пользователя.
 * Добавляем колонку created_at, которой по дефолту ставится текущая дата и время благодаря
 * DEFAULT CURRENT_TIMESTAMP.
 * 
 * Также мы хотим, чтобы почта и телефон пользователя при регистрации были уникальными.
 * То есть, чтобы пользователь не мог зарегестрировать под одним номером телефона или почтой
 * два аккаунта.
 * Либо используем в определении колонки UNIQUE,
 * Либо создаем UNIQUE INDEX по каждой из колонок.
 * 
 * INDEX отвечает за быстрый поиск. Самый быстрый поиск - по primary key. Но primary key может быть
 * только один в таблице.
 * 
 * Когда используется индекс?
 * Когда мы часто ищем какую-то информацию для значения, которое участвует в индексе.
 * Например, мы ищем имя пользователя, зная его email (это будет частый запрос в БД).
 * По email есть индекс, значит поиск произойдет быстрее.
 * 
 * Уникальный индекс - тот же самый индекс, который дополнительно гарантирует, что все значения в колонке уникальны.
 * 
 * Злоупотреблять индексами нельзя. Много индексов - медленно работают запросы.
 * 
 */

CREATE TABLE users(
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(145) NOT NULL,
	last_name VARCHAR(145) NOT NULL,
	email VARCHAR(145) NOT NULL UNIQUE,
	phone CHAR(11) NOT NULL,
	password_hash CHAR(65) DEFAULT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- NOW()
	INDEX (phone),
	INDEX (email)
);


-- Заполним таблицу, добавим Петю и Васю
INSERT INTO users VALUES (DEFAULT, 'Petya', 'Petukhov', 'petya@mail.com', '89212223334', DEFAULT, DEFAULT);
INSERT INTO users VALUES (DEFAULT, 'Vasya', 'Vasilkov', 'vasya@mail.com', '89212023334', DEFAULT, DEFAULT);

-- Посмотрим на содержимое таблицы
SELECT * FROM users;

-- описание таблицы
DESCRIBE users;

-- скрипт создания таблицы
SHOW CREATE TABLE users;

/*
 * 2. Создадим таблицу с профилем пользователя, чтобы не хранить все данные в таблице users
 * 
 * Сценарий: Необходимо хранить личную информацию пользователей в отдельной таблице.
 * 
 * Какая личная информация нам нужна: пол, возраст, фотография, город, страна.
 * Но как связать пользователя с его личной информацией?
 * 
 * Мы можем сделать это с помощью ссылки на таблицу users. То есть ссылки на конкретного
 * пользователя в таблице users.
 *
 * Например, у Пети id = 1 в таблице users. В таблице profiles мы делаем запись с user_id = 1
 * и можем гарантировать, что в этой записи содержится личная информация Пети. То есть, user_id = 1
 * говорит нам о том, что в записи содержится информация именно для пользователя из таблицы users с 
 * id = 1 и ни для кого другого.
 * 
 * Для связи между таблицами создается foreign key. Он гарантирует, что для каждого user_id существует
 * id в таблице profiles. А также то, что не существует user_id, которому не соответсвует никакой id в users.
 * CONSTRAINT fk_profiles_users FOREIGN KEY (user_id) REFERENCES users (id)
 * 
 * Одному пользователю соответствует один профиль. Связь один к одному.
 * 
*/
-- 1:1 связь
CREATE TABLE profiles(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	gender ENUM('f', 'm', 'x') NOT NULL,
	birthday DATE NOT NULL,
	photo_id INT UNSIGNED,
	city VARCHAR(130),
	country VARCHAR(130),
	FOREIGN KEY (user_id) REFERENCES users(id) -- ON DELETE CASCADE ON UPDATE CASCADE -- https://dev.mysql.com/doc/refman/8.0/en/create-table-foreign-keys.html 
	
);
 -- изменяем тип данных для колонки photo_id, чтобы соответствовал media(id)
ALTER TABLE profiles MODIFY COLUMN photo_id BIGINT UNSIGNED;


/*
 * 3. Поработаем с колонкой таблицы profiles, добавлением, модификацией, удалением
*/
DESCRIBE profiles;
-- Добавим колонку с номером паспорта

ALTER TABLE profiles ADD COLUMN passport_number VARCHAR(10);
-- Изменим ее тип
ALTER TABLE profiles MODIFY COLUMN passport_number VARCHAR(20);
-- Переименуем ее
ALTER TABLE profiles RENAME COLUMN passport_number TO passport;
-- Добавим индекс на колонку
ALTER TABLE profiles ADD KEY passport_idx (passport);
-- Удалим индекс
ALTER TABLE profiles DROP INDEX passport_idx;
-- Удалим колонку
ALTER TABLE profiles DROP COLUMN passport;

-- Заполним таблицу, добавим профили для уже созданных Пети и Васи
INSERT INTO profiles VALUES (1, 'm', '1997-12-01', NULL, 'Moscow', 'Russia'); -- профиль Пети
INSERT INTO profiles VALUES (2, 'm', '1988-11-02', NULL, 'Moscow', 'Russia'); -- профиль Васи

-- пытаемся добавить профиль для несуществующего пользователя
INSERT INTO profiles VALUES (3, 'm', '1988-11-02', NULL, 'Moscow', 'Russia'); 

SELECT * FROM profiles;
/*
 * 4. Создадим таблицу с сообщениями пользователей.
 * 
 * Сценарий: Петя отправляет Васе личное сообщение.
 * 
 * Петя может написать сообщения Васе, Сереже, Грише, а Вася может написать также сообщения Пете, Сереже, Грише.
 * Это связь от многих (пользователей) к многим (пользователям).
 * 
 * Что нам необходимо хранить для сообщения? Отправителя сообщения, получателя сообщения, текст сообщения,
 * дату и время создания сообщения и дату и время обновления сообщения. Также можно хранить информацию о том,
 * прочитано ли сообщение.
 * 
 * Отправитель сообщения - это наш Петя. Когда мы смотрим на сообщение в Вконтакте мы видим имя и фамилию отправителя.
 * Нужно ли нам хранить имя и фамилию отправителя в таблице сообщений?
 * Нет, эта информация уже хранится в таблице users, ее нет необходимости дублировать.
 * Мы можем хранить ссылку на отправителя сообщения, Петю из таблицы users. То есть его id из таблицы users.
 * 
 * Обозначим отправителя сообщения через from_user_id. Значит, в from_user_id мы храним 1, id Пети.
 * С этой 1 мы сможем пойти в таблицу users, найти там запись с id = 1, и достать имя и фамилию Пети.
 * 
 * Аналогично для Васи, создаем поле to_user_id - ссылку на получателя сообщения из таблицы users.
 * Будем хранить в to_user_id 2, иначе - id Васи из таблицы users.
 * 
 * 
 * Нам необходимо определить, нужен ли нам айди сообщения в данной таблице. То есть, нужно ли нам как-то уникально
 * идентифицировать каждое сообщение от Пети к Васе, может ли Петя писать несколько сообщений Васе, необходимо
 * ли нам различать эти сообщения?
 * Да, необходимо.
 * Добавляем id сообщения с авто-инкрементом и primary key.
 * 
 * Для связи отправителя сообщения с таблицей users и получателя сообщения с таблицей users создаем два разных
 * FOREIGN KEY, которые направлены на одну и ту же колонку users id.
 * Отправитель сообщения и получатель могут как совпадать, так и не совпадать для одного сообщения. Foreign key
 * нас никак не ограничивает.
 * 
 * Для быстрого поиска всех сообщений, которые отправил отправитель сообщения с конкретным id (например, ищем
 * все сообщения, которые отправил Петя со своим id = 1) создадим индекс
 * для from_user_id. Он неуникальный, так как отправитель сообщения мог отправить много разных сообщений,
 * он может встречаться в нескольких разных записях как отправитель.
 * 
 * Аналогично для получателя сообщения, to_user_id, чтобы быстро искать все сообщения, которые он получил.
 * (Например, все сообщения, которые получил Вася)
 * 
*/

-- автор сообщения : сообщение
-- 1 : М
-- 1 : 1

CREATE TABLE messages(
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED AUTO_INCREMENT NOT NULL
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	txt TEXT NOT NULL,
	is_delivered BOOLEAN DEFAULT FALSE,
	created_at DATETIME NOT NULL DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
	INDEX messages_from_user_id_idx (from_user_id),
	INDEX messages_to_user_id_idx (to_user_id),
	CONSTRAINT fk_messages_from_user_id FOREIGN KEY (from_user_id) REFERENCES users (id),
	CONSTRAINT fk_messages_to_user_id FOREIGN KEY (to_user_id) REFERENCES users (id)
);

DESCRIBE messages;

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Hi!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 1
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Vasya!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2
INSERT INTO messages VALUES (DEFAULT, 2, 1, 'Hi, Petya', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2

-- смотрим на сообщения
SELECT * FROM messages;

/*
 * 5. Создадим таблицу запросов в друзья.
 * 
 * Сценарий: Петя хочет добавить Васю в друзья.
 * 
 * Петя может отправить запросы на дружбу Васе, Сереже, Грише, Вася также может отправить запросы Пете, Сереже, Грише.
 * Это связь от многих (пользователей) к многим (пользователям).
 * 
 * Что нам необходимо хранить для запросов в друзья? Отправителя запроса, получателя запроса,
 * статус запроса (принят или отклонен).
 * 
 * Аналогичная ситуация, которая возникла при создании таблицы messages.
 * Мы отдельно храним ссылку на отправителя запроса, from_user_id, и получателя запроса, to_user_id.
 * 
 * Нам необходимо определить, нужен ли нам айди запроса на дружбу в данной таблице. 
 * То есть, изначально определить, может ли Петя послать несколько запросов на дружбу Васе одновременно?
 * Нет, не может. Петя может отправить Васе только один запрос на дружбу. Идентификатор не нужен.
 * 
 * Однако нам нужно уникально идентифицировать пару отправителя запроса и получателя, чтобы Петя не мог
 * несколько раз отправить запрос на дружбу Васе.
 * Для этого мы можем использовать PRIMARY KEY по двум колонкам, так как он у нас не занят.
 * PRIMARY KEY нам будет гарантировать, что пара (Петя, Вася), где Петя - отправитель, Вася - получатель,
 * будет встречаться в таблице всего один раз.
 * 
 * Аналогично таблице messages добавляем foreign keys и индексы.
 * 
*/

CREATE TABLE friend_requests(
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	accepted BOOLEAN DEFAULT FALSE,
	PRIMARY KEY(from_user_id, to_user_id),
	INDEX friend_requests_from_user_id_idx (from_user_id),
	INDEX friend_requests_to_user_id_idx (to_user_id),
	CONSTRAINT fk_friend_requests_from_user_id FOREIGN KEY (from_user_id) REFERENCES users (id),
	CONSTRAINT fk_friend_requests_to_user_id FOREIGN KEY (to_user_id) REFERENCES users (id)
);


-- Добавим запрос на дружбу от Пети к Васе
INSERT INTO friend_requests VALUES (1, 2, 1);

SELECT * FROM friend_requests;

INSERT INTO friend_requests (from_user_id, to_user_id) VALUES (2, 1);
INSERT INTO friend_requests (from_user_id, to_user_id) VALUES (3, 1);

/*
 * 6. Создадим таблицу сообществ.
 * 
 * Сценарий: Петя создает сообщество.
 * 
 * Петя может создать много сообществ, однако у сообщества может быть только один создатель.
 * Связь от одного (пользователя) к многим (сообществам).
 * 
 * Что нам необходимо хранить для сообщества? Его айди, название, описание, создателя сообщества.
 * 
 * Создатель сообщества - это пользователь. Значит, по стандартной схеме, мы можем хранить ссылку на пользователя
 * на таблицу users. То есть id пользователя из таблицы users. Сразу же создаем и foreign key.
 * Необходимо запомнить, что при связи от одного к многим ссылка и соответсвенно foreign key создается
 * на стороне многих, то есть сообщества в данном случае.
 * 
 * Добавляем также индекс на создателя сообщества (admin_id) для быстрого поиска всех сообществ, у которых создатель
 * пользователь с конкретным id.
 * 
*/
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150) NOT NULL,
	description VARCHAR(255),
	admin_id BIGINT UNSIGNED NOT NULL,
	KEY (admin_id),
	FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- Добавим сообщество с создателем Петей
INSERT INTO communities VALUES (DEFAULT, 'Number1', 'I am number one', 1);
INSERT INTO communities VALUES (DEFAULT, 'Number2', 'I am number two', 1);


SELECT * FROM communities;
/*
 * 7. Создадим таблицу для хранения информации обо всех участниках всех сообществ.
 * 
 * Сценарий: Вася вступил в сообщество Number1.
 * 
 * Вася может вступить во много разных сообществ, при этом в одном сообществе может быть много участников.
 * Связь от многих к многим.
 * 
 * Что нам необходимо хранить? Пользователя, сообщество, в которое он вступил, дату вступления в сообщество.
 * 
 * Так как Вася может вступить в сообщество Number1 только один раз, уникальный идентификатор записи нам не нужен (id),
 * используем спецификацию таблицы friend_requests как макет и создаем по аналогии.
*/
-- пользователи : сообщества
-- М : 1
-- 1 : М

-- Таблица связи пользователей и сообществ
CREATE TABLE communities_users(
	community_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(community_id, user_id),
	KEY (community_id),
	KEY (user_id),
	FOREIGN KEY (community_id) REFERENCES communities (id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);


-- Добавим запись вида Вася участник сообщества Number 1
INSERT INTO communities_users VALUES (1, 2, DEFAULT);

SELECT * FROM communities_users;
/*
 * 8. Создадим таблицу для хранения типов медиа файлов, каталог типов медифайлов.
 * 
 * В таблице-каталоге обычно не хранятся ссылки на другие таблицы.
 * В таблице-каталоге обычно хранятся только айди и название, в данном случае айди типа
 * медиа-файла и название медиа-файла.
 * 
 * Аналогичные каталоги можно создать для списка городов, стран, ...
*/
CREATE TABLE media_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

-- Добавим типы в каталог
INSERT INTO media_types VALUES (DEFAULT, 'изображение');
INSERT INTO media_types VALUES (DEFAULT, 'музыка');
INSERT INTO media_types VALUES (DEFAULT, 'документ');

SELECT * FROM media_types;

/*
 * 9. Создадим таблицу всех медиафайлов.
 * 
 * Сценарий: Петя добавляет фотографию.
 * 
 * Петя может добавить много различных медиафайлов, однако у медиафайла может быть только один автор 
 * (тот, кто его добавил).
 * Связь от одного (пользователя) к многим (медиафайлам).
 * 
 * Что нам необходимо хранить для медиафайла? Его айди, создателя, тип, название, размер, дату добавления.
 * 
 * Ссылку на создателя (пользователя) создаем по аналогии с ранее созданными таблицами, добавляем индекс для
 * быстрого поиска медиафайлов пользователя и foreign key.
 * 
 * Также необходимо как-то хранить тип медиа-файла. Можно хранить название типа медиафайла, например, "изображение",
 * "музыка", "документ". Однако, названия типов медиафайлов у нас уже хранятся в нашем каталоге media_types и это будет
 * дублирование данных. Так мы можем хранить не название типа, а ссылку на название типа в каталоге (то есть id типа 
 * медиафайла из таблицы media_types).
 * 
 * У каждого типа медиафайла может быть множество медиафайлов (тип "изображение" может быть у множества медиафайлов),
 * однако у медиафайла может быть только один тип (фотография1 имеет только один тип - "изображение").
 * Так это связь от одного (типа) к многим (медиафайлам).
 * 
 * Создаем колонку media_types_id, где храним id типа из media_types. Создаем foreign key от media_types_id
 * к media_types (id). Индекс не создаем, так как типов медиафайлов будет мало, и индекс будет плохо работать
 * по такой колонке с часто повторяющимися значениями. 
 * 
 * Так в данной таблице у нас получилось две разных связи от одного к многим, которые не связаны между собой.
*/
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_types_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255) COMMENT '/files/folder/img.png',
	file_size BIGINT UNSIGNED,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	KEY (media_types_id),
	KEY (user_id),
	FOREIGN KEY (media_types_id) REFERENCES media_types(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Добавим два изображения, которые добавил Петя
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im.jpg', 100, DEFAULT);
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im1.png', 78, DEFAULT);
-- Добавим документ, который добавил Вася
INSERT INTO media VALUES (DEFAULT, 2, 3, 'doc.docx', 1024, DEFAULT);

SELECT * FROM media;

DESCRIBE media;

