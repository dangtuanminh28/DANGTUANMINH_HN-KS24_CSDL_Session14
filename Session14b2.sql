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

ALTER TABLE posts 
ADD COLUMN likes_count INT DEFAULT 0;

-- Lần đầu commit
START TRANSACTION;
INSERT INTO likes (post_id, user_id) VALUES (1, 2);
UPDATE posts SET likes_count = likes_count + 1 WHERE post_id = 1;
COMMIT;

-- Lần 2 commit
START TRANSACTION;
INSERT INTO likes (post_id, user_id) VALUES (1, 2);
UPDATE posts SET likes_count = likes_count + 1 WHERE post_id = 1;
ROLLBACK;