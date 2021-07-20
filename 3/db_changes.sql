USE vk;

ALTER TABLE friend_requests ADD CONSTRAINT sender_is_not_receiver_check CHECK (from_user_id <> to_user_id);
ALTER TABLE users ADD CONSTRAINT phone_check CHECK (regexp_like(phone, '^\d{11}$'));
ALTER TABLE profiles ADD CONSTRAINT `profile_media_fk` FOREIGN KEY (photo_id) REFERENCES media (id);
ALTER TABLE profiles ADD CONSTRAINT `profile_user_fk` FOREIGN KEY (user_id) REFERENCES users (id);

UPDATE media_types SET `name` = 'image' WHERE `id` = 1;
UPDATE media_types SET `name` = 'audio' WHERE `id` = 2;
UPDATE media_types SET `name` = 'video' WHERE `id` = 3;
UPDATE media_types SET `name` = 'document' WHERE `id` = 4;

DELETE FROM friend_requests WHERE from_user_id = to_user_id;







