drop database if exists session11;
create database session11;
use session11;

create table users (
	user_id int primary key auto_increment,
    username varchar(50) unique not null,
    post_count int default(0)
);

create table posts (
	post_id int primary key auto_increment,
	user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

create table likes (
	like_id int primary key auto_increment,
    post_id int,
    user_id int,
	unique key unique_like (post_id, user_id),
    foreign key (user_id) references users(user_id),
	foreign key (post_id) references posts(post_id)
);

create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id),
    foreign key (follower_id) references users(user_id),
    foreign key (followed_id) references users(user_id)
);

INSERT INTO users (username, post_count) VALUES
('Đặng Tuấn Minh', 3),
('Nguyễn Khoan Nam', 4),
('Phạm Duy Anh', 9),
('Phan Hữu Tuệ', 5);

INSERT INTO posts (user_id, content) VALUES
(3, 'Hello world from Alice!'),
(1, 'Second post by Alice'),
(4, 'Bob first post'),
(2, 'Charlie sharing thoughts');

INSERT INTO likes (post_id , user_id) VALUES
(1, 2),
(3, 4),
(2, 3),
(4, 1);

INSERT INTO followers (follower_id , followed_id) VALUES
(4, 2),
(1, 3),
(2, 1),
(3, 4);

DELIMITER //
CREATE PROCEDURE sp_follow_user (IN p_follower_id INT, IN p_followed_id INT)
BEGIN
    DECLARE v_count INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
    IF p_follower_id = p_followed_id THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể tự follow chính mình';
    END IF;

    -- Kiểm tra follower tồn tại
    SELECT COUNT(*) INTO v_count FROM users WHERE user_id = p_follower_id;
    IF v_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Follower không tồn tại';
    END IF;

    -- Kiểm tra followed tồn tại
    SELECT COUNT(*) INTO v_count FROM users WHERE user_id = p_followed_id;
    IF v_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User được follow không tồn tại';
    END IF;

    -- Kiểm tra chưa follow trước đó
    SELECT COUNT(*) INTO v_count FROM followers 
    WHERE follower_id = p_follower_id AND followed_id = p_followed_id;

    IF v_count > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã follow trước đó';
    END IF;

    INSERT INTO followers (follower_id, followed_id) VALUES (p_follower_id, p_followed_id);

    UPDATE users SET following_count = following_count + 1 WHERE user_id = p_follower_id;
    UPDATE users SET followers_count = followers_count + 1 WHERE user_id = p_followed_id;
    COMMIT;
END //
DELIMITER ;