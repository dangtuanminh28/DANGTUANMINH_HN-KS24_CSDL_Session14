drop database if exists session14;
create database session14;
use session14;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username, total_posts) 
VALUES ('Nguyễn Văn A', 0),
		('Lê Thị B', 0),
        ('Đặng Khánh C', 0),
        ('Trần Thị D', 0);

INSERT INTO posts (user_id, content) 
VALUES  (4, 'Bún gói'),
		(2, 'Bánh gạo'),
        (3, 'Mì gói'),
        (1, 'cơm chiên');
		

DELIMITER //
CREATE PROCEDURE sp_createPost (IN p_user_id INT, IN p_content TEXT)
BEGIN
    -- Biến lưu thông báo lỗi
    DECLARE v_error_msg VARCHAR(255);
    -- Bắt mọi lỗi SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Có lỗi xảy ra khi đăng bài. Giao dịch đã bị hủy.';
    END;

    START TRANSACTION;
    -- Kiểm tra nội dung
    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nội dung bài viết không được trống';
    END IF;

    -- Insert post
    INSERT INTO posts(user_id, content) VALUES (p_user_id, p_content);

    -- Update số bài viết
    UPDATE users SET total_posts = total_posts + 1 WHERE user_id = p_user_id;
    COMMIT;
END //
DELIMITER ;

-- Case 1
CALL sp_createPost(1, 'Bài viết hợp lệ');
select user_id, username, total_posts from users where user_id = 1;
select post_id, user_id, content, created_at from posts where user_id = 1;

-- Case 2
CALL sp_createPost(9999, 'Test lỗi');
select post_id, user_id, content, created_at from posts where user_id = 9999;
