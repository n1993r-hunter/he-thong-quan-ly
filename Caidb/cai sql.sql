-- Tạo Database (Schema) mới cho dự án
CREATE DATABASE IF NOT EXISTS he_thong_quan_ly;
USE he_thong_quan_ly;
-- 1. Bảng USERS [cite: 210]
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng GROUPS (Lưu ý: Dùng dấu backtick ` ` vì GROUP là từ khóa nhạy cảm trong SQL) [cite: 212]
CREATE TABLE `GROUPS` (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    created_by INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);

-- 3. Bảng GROUP_MEMBERS [cite: 215]
CREATE TABLE GROUP_MEMBERS (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT,
    user_id INT,
    role VARCHAR(20) DEFAULT 'member',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 4. Bảng TASKS [cite: 218]
CREATE TABLE TASKS (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_by INT,
    deadline DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'todo',
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);

-- 5. Bảng TASK_ASSIGNMENTS [cite: 220]
CREATE TABLE TASK_ASSIGNMENTS (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT,
    user_id INT,
    progress INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'todo',
    submitted_at DATETIME,
    completed_at DATETIME,
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 6. Bảng TASK_PROGRESS_LOGS [cite: 222]
CREATE TABLE TASK_PROGRESS_LOGS (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT,
    updated_by INT,
    old_progress INT,
    new_progress INT NOT NULL,
    note TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES TASK_ASSIGNMENTS(assignment_id),
    FOREIGN KEY (updated_by) REFERENCES USERS(user_id)
);

-- 7. Bảng SUBTASKS [cite: 224]
CREATE TABLE SUBTASKS (
    subtask_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT,
    title VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'todo',
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id)
);

-- 8. Bảng TASK_COMMENTS [cite: 226]
CREATE TABLE TASK_COMMENTS (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 9. Bảng STOCKS [cite: 228]
CREATE TABLE STOCKS (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    group_id INT,
    stock_code VARCHAR(20) UNIQUE,
    current_price FLOAT DEFAULT 100,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id)
);

-- 10. Bảng STOCK_PRICE_HISTORY [cite: 230]
CREATE TABLE STOCK_PRICE_HISTORY (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT,
    price_before FLOAT NOT NULL,
    price_after FLOAT NOT NULL,
    change_reason VARCHAR(100) NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES STOCKS(stock_id)
);

-- 11. Bảng ACTIVITY_LOGS [cite: 232]
CREATE TABLE ACTIVITY_LOGS (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    group_id INT,
    task_id INT,
    activity_type VARCHAR(50) NOT NULL,
    activity_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id)
);

-- 12. Bảng PEER_REVIEWS [cite: 234]
CREATE TABLE PEER_REVIEWS (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_id INT,
    reviewed_user_id INT,
    task_id INT,
    review_type VARCHAR(20) NOT NULL,
    group_id INT,
    score INT CHECK (score BETWEEN 1 AND 10),
    comment TEXT,
    review_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES USERS(user_id),
    FOREIGN KEY (reviewed_user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id)
);

-- 13. Bảng SCORING_WEIGHTS [cite: 236]
CREATE TABLE SCORING_WEIGHTS (
    weight_id INT AUTO_INCREMENT PRIMARY KEY,
    component VARCHAR(20) UNIQUE,
    weight FLOAT NOT NULL
);

-- 14. Bảng REWARD_PENALTY_RULES [cite: 238]
CREATE TABLE REWARD_PENALTY_RULES (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    score_change INT NOT NULL,
    description TEXT
);