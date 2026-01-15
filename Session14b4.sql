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
(4, 2, 'Comment 1'),
(1, 3, 'Comment 2'),
(2, 1, 'Comment 3'),
(3, 4, 'Comment 4');

DELIMITER //
CREATE PROCEDURE sp_post_comment (IN p_post_id INT, IN p_user_id INT, IN p_content TEXT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi nghiêm trọng, rollback toàn bộ';
    END;

    START TRANSACTION;
    -- Insert comment
    INSERT INTO comments(post_id, user_id, content) VALUES (p_post_id, p_user_id, p_content);

    -- Savepoint sau khi insert thành công
    SAVEPOINT after_insert;

    -- Test bug
    UPDATE posts SET comments_count = comments_count + 1 WHERE post_id = p_post_id;

    -- Nếu update ko đc
    IF ROW_COUNT() = 0 THEN
        ROLLBACK TO after_insert;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi khi cập nhật comments_count';
    END IF;
    
    COMMIT;
END //
DELIMITER ;

-- Test thành công
CALL sp_post_comment(1, 2, 'Bình luận hợp lệ');
-- Test bug
CALL sp_post_comment(9999, 2, 'Bình luận ko hợp lệ');
