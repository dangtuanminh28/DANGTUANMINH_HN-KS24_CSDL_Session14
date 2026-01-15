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

-- Test thành công
START TRANSACTION;
INSERT INTO posts (user_id, content) VALUES (1, 'Bài viết mới');
UPDATE users SET post_count = post_count + 1 WHERE user_id = 1;
COMMIT;

SELECT user_id, username, post_count FROM users WHERE user_id = 1;
SELECT post_id, user_id, content, created_at FROM posts WHERE user_id = 1;

-- Test ko thành công
START TRANSACTION;
INSERT INTO posts (user_id, content) VALUES (9999, 'Bài viết lỗi');

UPDATE users SET post_count = post_count + 1 WHERE user_id = 9999;
ROLLBACK;

SELECT user_id, username, post_count FROM users WHERE user_id = 9999;
SELECT post_id, user_id, content, created_at FROM posts WHERE user_id = 9999;