/*
 * Пусть задан некоторый пользователь. 
 * Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
 */

-- Некий пользователь
SET @target_user_id := 7;

-- (1) Количество сообщений, которые отправил данный пользователь другим пользователям
SELECT to_user_id AS user_id, COUNT(*) AS messages_count 
FROM messages 
WHERE from_user_id = @target_user_id
GROUP BY to_user_id;

-- (2) Количество сообщений, которые данному пользователю отправили другие пользователи
SELECT from_user_id AS user_id, COUNT(*) AS messages_count 
FROM messages 
WHERE to_user_id = @target_user_id
GROUP BY from_user_id;

-- (3) Выбираем друзей пользователя
SELECT DISTINCT IF(from_user_id = @target_user_id, to_user_id, from_user_id) AS friend_id 
FROM friend_requests
WHERE (from_user_id = @target_user_id OR to_user_id = @target_user_id) AND request_type = (
	SELECT id FROM friend_requests_types WHERE name = 'accepted'
);

-- (4) Объединяем (1) и (2), суммируя сообщения, добавляем условие (3)
SELECT user_id FROM 
(
	SELECT to_user_id AS user_id, COUNT(*) AS messages_count 
	FROM messages 
	WHERE from_user_id = @target_user_id
	GROUP BY to_user_id
	
	UNION
	
	SELECT from_user_id AS user_id, COUNT(*) AS messages_count 
	FROM messages 
	WHERE to_user_id = @target_user_id
	GROUP BY from_user_id
) AS msg
WHERE user_id IN 
(
	SELECT DISTINCT IF(from_user_id = @target_user_id, to_user_id, from_user_id) AS friend_id 
	FROM friend_requests
	WHERE (from_user_id = @target_user_id OR to_user_id = @target_user_id) AND request_type = (
		SELECT id FROM friend_requests_types WHERE name = 'accepted'
	)
)
GROUP BY user_id
ORDER BY SUM(messages_count) DESC
LIMIT 1;



/*
 * Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
 */

-- (1) 10 самых молодых пользователей
SELECT user_id FROM profiles ORDER BY TIMESTAMPDIFF(YEAR, birthday, NOW()) DESC LIMIT 10;

-- (2) Считаем лайки
SELECT COUNT(*) AS total_likes_count FROM posts_likes WHERE user_id IN
(
	SELECT user_id FROM
	(
		SELECT user_id FROM profiles ORDER BY TIMESTAMPDIFF(YEAR, birthday, NOW()) DESC LIMIT 10
	) AS ten_youngest_users
) AND like_type = 1;



/*
 * Определить кто больше поставил лайков (всего) - мужчины или женщины?
 */

-- (1) Лайки мужчин
SET @male_likes_count := 
(
	SELECT COUNT(*) FROM posts_likes WHERE like_type = 1 AND user_id IN
	(
		SELECT user_id FROM profiles WHERE gender = 'm'
	)
);

-- (2) Лайки женщин
SET @female_likes_count := 
(
	SELECT COUNT(*) FROM posts_likes WHERE like_type = 1 AND user_id IN
	(
		SELECT user_id FROM profiles WHERE gender = 'f'
	)
);

-- (3) Кто больше поставил лайков?
SELECT IF(@male_likes_count > @female_likes_count, 'Мужчины поставили больше лайков', 
	IF(@male_likes_count < @female_likes_count, 'Женщины поставили больше лайков', 'Поровну!')
) AS more_likes;



/*
 * Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
 * (Считаем каждую активность за 1 балл.)
 */

-- (0) Выбираем 10 самых неактивных пользователей из объединенного запроса.
SELECT user_id, SUM(ct) AS rating FROM
(
	
		-- (1) Количество сообществ у каждого пользователя
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT user_id FROM communities_users
		)
		UNION
		(
			SELECT user_id, COUNT(*) AS ct FROM communities_users
			GROUP BY user_id
		)
	
	UNION
	
		-- (2) Количество отправленных запросов в друзья
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT from_user_id FROM friend_requests
		)
		UNION
		(
			SELECT from_user_id AS user_id, COUNT(*) AS ct FROM friend_requests
			GROUP BY from_user_id
		)
	
	UNION 
	
		-- (3) Количество загруженных медиа
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT user_id FROM media
		)
		UNION
		(
			SELECT user_id, COUNT(*) AS ct FROM media
			GROUP BY user_id
		)
	
	UNION 
	
		-- (4) Количество отправленных сообщений
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT from_user_id FROM messages
		)
		UNION
		(
			SELECT from_user_id AS user_id, COUNT(*) AS ct FROM messages
			GROUP BY from_user_id
		)
	
	UNION
	
		-- (5) Количество постов
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT user_id FROM posts
		)
		UNION
		(
			SELECT user_id, COUNT(*) AS ct FROM posts
			GROUP BY user_id
		)
	
	UNION 
	
		-- (6) Количество лайков
		SELECT id AS user_id, 0 AS ct FROM users WHERE id NOT IN
		(
			SELECT DISTINCT user_id FROM posts_likes
		)
		UNION
		(
			SELECT user_id, SUM(like_type) AS ct FROM posts_likes
			GROUP BY user_id
		)
	
) AS united_rating
GROUP BY user_id
ORDER BY rating ASC
LIMIT 10;






























































