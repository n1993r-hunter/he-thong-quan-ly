-- =========================================================
-- DATABASE FINAL RÚT GỌN: Hệ thống đánh giá hiệu suất nhóm
-- Mô hình: Mỗi thành viên là một "mã cổ phiếu cá nhân"
-- Stock ban đầu = 100
-- Không zero-sum: người này tăng điểm không làm người khác bị trừ
-- Review: AI / Peer / Leader đều dùng thang 1-5 sao
-- =========================================================

DROP DATABASE IF EXISTS he_thong_quan_ly;

CREATE DATABASE he_thong_quan_ly
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE he_thong_quan_ly;

-- =========================================================
-- 1. USERS
-- =========================================================
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. GROUPS
-- =========================================================
CREATE TABLE `GROUPS` (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);

-- =========================================================
-- 3. GROUP_MEMBERS
-- =========================================================
CREATE TABLE GROUP_MEMBERS (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(20) DEFAULT 'member',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),

    UNIQUE (group_id, user_id)
);

-- =========================================================
-- 4. GROUP_JOIN_REQUESTS
-- Người dùng gửi yêu cầu tham gia nhóm
-- =========================================================
CREATE TABLE GROUP_JOIN_REQUESTS (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME,
    reviewed_by INT,

    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (reviewed_by) REFERENCES USERS(user_id),

    UNIQUE (group_id, user_id)
);

-- =========================================================
-- 5. TASKS
-- =========================================================
CREATE TABLE TASKS (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_by INT NOT NULL,
    deadline DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'todo',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);

-- =========================================================
-- 6. TASK_ASSIGNMENTS
-- Một task có thể giao cho nhiều người
-- Một người không bị giao trùng cùng một task
-- =========================================================
CREATE TABLE TASK_ASSIGNMENTS (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    progress INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'todo',
    submitted_at DATETIME,
    completed_at DATETIME,

    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),

    UNIQUE (task_id, user_id),
    CHECK (progress BETWEEN 0 AND 100)
);

-- =========================================================
-- 7. STOCKS
-- Mỗi thành viên trong mỗi nhóm có một mã cổ phiếu riêng
-- current_price = giá trị hiệu suất hiện tại
-- Mặc định 100 = 100% ban đầu
-- =========================================================
CREATE TABLE STOCKS (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    stock_code VARCHAR(20) NOT NULL,
    current_price FLOAT DEFAULT 100,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),

    UNIQUE (user_id, group_id),
    UNIQUE (group_id, stock_code)
);

-- =========================================================
-- 8. STOCK_PRICE_HISTORY
-- Lưu lịch sử tăng/giảm stock để vẽ biểu đồ
-- Không zero-sum: chỉ cập nhật stock của chính người được đánh giá
-- =========================================================
CREATE TABLE STOCK_PRICE_HISTORY (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT NOT NULL,
    task_id INT,
    source_type VARCHAR(30) DEFAULT 'task_review',
    price_before FLOAT NOT NULL,
    price_after FLOAT NOT NULL,
    price_change FLOAT NOT NULL,
    change_reason VARCHAR(255) NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (stock_id) REFERENCES STOCKS(stock_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id)
);

-- =========================================================
-- 9. TASK_SUBMISSIONS
-- Một người có thể nộp lại file nhiều lần cho cùng một task
-- submit_version dùng để phân biệt lần nộp 1, 2, 3...
-- =========================================================
CREATE TABLE TASK_SUBMISSIONS (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    user_id INT NOT NULL,
    task_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50),
    submit_version INT DEFAULT 1,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (assignment_id) REFERENCES TASK_ASSIGNMENTS(assignment_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id)
);

-- =========================================================
-- 10. AI_EVALUATIONS
-- AI chấm từng lần nộp file
-- Một người có thể nộp nhiều lần, AI chấm nhiều lần
-- Khi tính stock đang lấy AI tốt nhất trong code Java
-- =========================================================
CREATE TABLE AI_EVALUATIONS (
    ai_evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    ai_star INT NOT NULL,
    converted_point INT NOT NULL,
    summary TEXT,
    strengths TEXT,
    weaknesses TEXT,
    raw_response TEXT,
    evaluated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (submission_id) REFERENCES TASK_SUBMISSIONS(submission_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),

    CHECK (ai_star BETWEEN 1 AND 5)
);

-- =========================================================
-- 11. PEER_REVIEWS
-- Thành viên đánh giá chéo nhau bằng sao 1-5
-- Khi tính điểm sẽ lấy sao trung bình của mọi người đánh giá người đó
-- =========================================================
CREATE TABLE PEER_REVIEWS (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_id INT NOT NULL,
    reviewed_user_id INT NOT NULL,
    task_id INT,
    group_id INT NOT NULL,
    star INT NOT NULL,
    comment TEXT,
    review_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (reviewer_id) REFERENCES USERS(user_id),
    FOREIGN KEY (reviewed_user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),

    CHECK (star BETWEEN 1 AND 5),
    CHECK (reviewer_id <> reviewed_user_id),

    UNIQUE (reviewer_id, reviewed_user_id, task_id)
);

-- =========================================================
-- 12. LEADER_REVIEWS
-- Nhóm trưởng đánh giá thành viên bằng sao 1-5
-- =========================================================
CREATE TABLE LEADER_REVIEWS (
    leader_review_id INT AUTO_INCREMENT PRIMARY KEY,
    leader_id INT NOT NULL,
    reviewed_user_id INT NOT NULL,
    task_id INT,
    group_id INT NOT NULL,
    star INT NOT NULL,
    comment TEXT,
    review_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (leader_id) REFERENCES USERS(user_id),
    FOREIGN KEY (reviewed_user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),

    CHECK (star BETWEEN 1 AND 5),
    CHECK (leader_id <> reviewed_user_id),

    UNIQUE (leader_id, reviewed_user_id, task_id)
);

-- =========================================================
-- 13. SCORING_WEIGHTS
-- Trọng số tính stock_change
-- AI 40%, Peer 30%, Leader 30%
-- =========================================================
CREATE TABLE SCORING_WEIGHTS (
    weight_id INT AUTO_INCREMENT PRIMARY KEY,
    component VARCHAR(20) UNIQUE,
    weight FLOAT NOT NULL
);

-- =========================================================
-- 14. REWARD_PENALTY_RULES
-- Quy đổi sao thành điểm cộng/trừ
-- 5 sao = +20
-- 4 sao = +10
-- 3 sao = 0
-- 2 sao = -10
-- 1 sao = -20
-- =========================================================
CREATE TABLE REWARD_PENALTY_RULES (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL UNIQUE,
    star_level INT,
    score_change INT NOT NULL,
    description TEXT,

    CHECK (star_level BETWEEN 1 AND 5)
);

-- =========================================================
-- 15. TASK_SCORE_SUMMARY
-- Lưu kết quả tổng hợp điểm của từng người trong từng task
-- Dùng để tránh cộng stock nhiều lần sai
-- =========================================================
CREATE TABLE TASK_SCORE_SUMMARY (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    group_id INT NOT NULL,

    best_ai_star FLOAT,
    avg_peer_star FLOAT,
    leader_star FLOAT,

    ai_point FLOAT DEFAULT 0,
    peer_point FLOAT DEFAULT 0,
    leader_point FLOAT DEFAULT 0,

    stock_change FLOAT DEFAULT 0,
    calculated_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (assignment_id) REFERENCES TASK_ASSIGNMENTS(assignment_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),

    UNIQUE (assignment_id)
);

-- =========================================================
-- 16. ACTIVITY_LOGS
-- Ghi log hoạt động cơ bản
-- Giữ lại vì Java đang có ActivityLogDAO
-- =========================================================
CREATE TABLE ACTIVITY_LOGS (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT,
    task_id INT,
    activity_type VARCHAR(50) NOT NULL,
    activity_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (group_id) REFERENCES `GROUPS`(group_id),
    FOREIGN KEY (task_id) REFERENCES TASKS(task_id)
);

-- =========================================================
-- DỮ LIỆU MẶC ĐỊNH
-- =========================================================

-- Trọng số đánh giá
INSERT INTO SCORING_WEIGHTS (component, weight)
VALUES
('ai', 0.4),
('peer', 0.3),
('leader', 0.3);

-- Quy đổi sao sang điểm cộng/trừ stock
INSERT INTO REWARD_PENALTY_RULES (event_type, star_level, score_change, description)
VALUES
('star_5', 5, 20, '5 sao - Làm rất tốt, vượt yêu cầu'),
('star_4', 4, 10, '4 sao - Làm tốt, tương đối ổn'),
('star_3', 3, 0, '3 sao - Làm tròn vai, đạt yêu cầu'),
('star_2', 2, -10, '2 sao - Làm kém, thiếu nhiều'),
('star_1', 1, -20, '1 sao - Gần như không đóng góp');

-- =========================================================
-- KIỂM TRA NHANH SAU KHI CHẠY
-- =========================================================

SELECT * FROM SCORING_WEIGHTS;
SELECT * FROM REWARD_PENALTY_RULES;