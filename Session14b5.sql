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

create table comments (
    comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id),
	foreign key (post_id) references posts(post_id)
);

create table delete_log (
    log_id int primary key auto_increment,
    post_id int not null,
    deleted_by int not null,
    deleted_at datetime default current_timestamp
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

INSERT INTO comments (post_id, user_id, content) VALUES
(4, 2, 'Bánh mì'),
(1, 3, 'Cơm chiên'),
(2, 1, 'Mì tôm'),
(3, 4, 'Snack');

INSERT INTO delete_log (post_id, deleted_by) VALUES
(1, 3),
(2, 1),
(3, 4),
(4, 2);

DELIMITER //
CREATE PROCEDURE sp_delete_post (IN p_post_id INT, IN p_user_id INT)
BEGIN
    DECLARE v_owner_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Có lỗi xảy ra, giao dịch đã bị rollback';
    END;

    START TRANSACTION;
    -- Kiểm tra bài viết tồn tại và đúng chủ sở hữu
    SELECT user_id INTO v_owner_id
    FROM posts WHERE post_id = p_post_id;

    IF v_owner_id IS NULL OR v_owner_id <> p_user_id THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bài viết không tồn tại hoặc không thuộc quyền sở hữu';
    END IF;

    -- Xóa bảng con trước
    DELETE FROM likes WHERE post_id = p_post_id;
    DELETE FROM comments WHERE post_id = p_post_id;

    DELETE FROM posts WHERE post_id = p_post_id;
    -- Giảm số bài viết của user
    UPDATE users SET post_count = post_count - 1 WHERE user_id = p_user_id;
    -- Ghi log
    INSERT INTO delete_log (post_id, deleted_by) VALUES (p_post_id, p_user_id);
    COMMIT;
END //
DELIMITER ;

-- Test thành công
CALL sp_delete_post(1, 3);
-- Test bug
CALL sp_delete_post(1, 2);