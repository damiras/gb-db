/* Добавляем время запроса дружбы и время подтверждения (если есть) */
ALTER TABLE `friend_requests` ADD COLUMN `accepted_at` DATETIME DEFAULT NULL;
ALTER TABLE `friend_requests` ADD COLUMN `requested_at` DATETIME NOT NULL DEFAULT NOW();

/* Сообщества могут быть закрытыми (вступление с подтверждением), также участники сообщества могут приглашать других пользователей */
ALTER TABLE `communities_users` ADD COLUMN `user_invited` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `communities_users` ADD COLUMN `accepted` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `communities_users` ADD COLUMN `accepted_at` DATETIME DEFAULT NULL;

/* Вместо одного админа добавим роли участникам сообщества, а главный админ пусть будет владельцем */
ALTER TABLE `communities` RENAME COLUMN `admin_id` TO `owner_id`;
CREATE TABLE `community_roles` (
	`id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(31) NOT NULL,
	`level` SMALLINT NOT NULL,
	`active` BOOLEAN NOT NULL DEFAULT TRUE
);
INSERT INTO `community_roles` (`name`, `level`) VALUES('Admin', 1000);
INSERT INTO `community_roles` (`name`, `level`) VALUES('Moderator', 500);
INSERT INTO `community_roles` (`name`, `level`) VALUES('Redactor', 100);
ALTER TABLE `communities_users` ADD COLUMN `role_id` SMALLINT UNSIGNED DEFAULT NULL;
ALTER TABLE `communities_users` ADD FOREIGN KEY (`role_id`) REFERENCES `community_roles` (`id`) ON DELETE SET DEFAULT ON UPDATE CASCADE; 

/* Для фотографий и аватарок лучше использовать отдельную таблицу, чтобы удобнее было генерировать фото разных размеров (типов) */
CREATE TABLE `photos` (
	`id` SERIAL PRIMARY KEY,
	`type` CHAR(15) DEFAULT NULL COMMENT 'e.g. large, medium, small, tiny',
	`user_id` BIGINT UNSIGNED DEFAULT NULL,
	`media_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'null for generated photos',
	`parent_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'not null for generated child photos',
	`file_name` VARCHAR(255) DEFAULT NULL COMMENT 'null for original photos, obtained from media table',
	`file_path` VARCHAR(255) DEFAULT NULL COMMENT 'null for original photos, obtained from media table',
	`mime_type` VARCHAR(31) DEFAULT NULL COMMENT 'null for original photos, obtained from media table',
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`parent_id`) REFERENCES `photos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	INDEX (`type`)
);
ALTER TABLE `media` ADD COLUMN `file_path` VARCHAR(255) DEFAULT NULL AFTER `file_name`;
ALTER TABLE `media` ADD COLUMN `file_href` VARCHAR(255) DEFAULT NULL AFTER `file_path`;
ALTER TABLE `media` ADD COLUMN `mime_type` VARCHAR(127) DEFAULT NULL AFTER `file_size`;
ALTER TABLE `media` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL AFTER `created_at`;
ALTER TABLE `media` ADD COLUMN `is_deleted` BOOLEAN DEFAULT FALSE AFTER `deleted_at`;
ALTER TABLE `communities` ADD COLUMN `photo_id` BIGINT UNSIGNED DEFAULT NULL;
ALTER TABLE `communities` ADD FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`) ON DELETE SET DEFAULT ON UPDATE CASCADE;
ALTER TABLE `profiles` ADD FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`);

/* Таблица стен */
CREATE TABLE `walls` (
	`id` SERIAL PRIMARY KEY,
	`profile_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'null for community walls',
	`community_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'null for profile walls',
	FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

/* Таблица постов */
CREATE TABLE `wall_posts` (
	`id` SERIAL PRIMARY KEY,
	`wall_id` BIGINT UNSIGNED NOT NULL,
	`user_id` BIGINT UNSIGNED NOT NULL,
	`community_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'not null for community posts',
	`title` VARCHAR(127) DEFAULT NULL,
	`body` TEXT,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	`updated_at` DATETIME DEFAULT NULL ON UPDATE NOW(),
	`disable_comments` BOOLEAN NOT NULL DEFAULT FALSE,
	FOREIGN KEY (`wall_id`) REFERENCES `walls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
); 

/* Таблица медиа, прикрепленных к постам */
CREATE TABLE `post_attachments` (
	`id` SERIAL PRIMARY KEY,
	`post_id` BIGINT UNSIGNED NOT NULL,
	`media_id` BIGINT UNSIGNED NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`post_id`) REFERENCES `wall_posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

/* Таблица лайков медиа */
CREATE TABLE `media_likes` (
	`id` SERIAL PRIMARY KEY,
	`user_id` BIGINT UNSIGNED NOT NULL,
	`media_id` BIGINT UNSIGNED NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

/* Таблица лайков постов */
CREATE TABLE `post_likes` (
	`id` SERIAL PRIMARY KEY,
	`user_id` BIGINT UNSIGNED NOT NULL,
	`post_id` BIGINT UNSIGNED NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`post_id`) REFERENCES `wall_posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

/* Таблица лайков профилей пользователей */
CREATE TABLE `profile_likes` (
	`id` SERIAL PRIMARY KEY,
	`user_id` BIGINT UNSIGNED NOT NULL,
	`profile_id` BIGINT UNSIGNED NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

/* Таблица лайков сообществ */
CREATE TABLE `community_likes` (
	`id` SERIAL PRIMARY KEY,
	`user_id` BIGINT UNSIGNED NOT NULL,
	`community_id` BIGINT UNSIGNED NOT NULL,
	`created_at` DATETIME NOT NULL DEFAULT NOW(),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


