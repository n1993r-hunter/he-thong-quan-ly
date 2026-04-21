USE he_thong_quan_ly;

-- --------------------------------------------------------
-- 1. USERS (1 Giảng viên và 9 Sinh viên)
-- --------------------------------------------------------
INSERT INTO USERS (full_name, email, username, password) VALUES 
('Thầy Nguyễn Văn Giảng', 'giangnv@uni.edu.vn', 'giang_gv', '123456'),
('Phạm Quang Hải', 'haipq.sv@uni.edu.vn', 'hai_dev', '123456'),
('Lê Thị Thùy Linh', 'linhltt.sv@uni.edu.vn', 'linh_ba', '123456'),
('Trần Hoàng Nam', 'namth.sv@uni.edu.vn', 'nam_tester', '123456'),
('Đỗ Minh Tuấn', 'tuandm.sv@uni.edu.vn', 'tuan_ai', '123456'),
('Nguyễn Hải Yến', 'yennh.sv@uni.edu.vn', 'yen_data', '123456'),
('Vũ Đức Sơn', 'sonvd.sv@uni.edu.vn', 'son_ai', '123456'),
('Bùi Quang Bách', 'bachbq.sv@uni.edu.vn', 'bach_algo', '123456'),
('Ngô Phương Thảo', 'thaonp.sv@uni.edu.vn', 'thao_algo', '123456'),
('Đặng Quốc Việt', 'vietdq.sv@uni.edu.vn', 'viet_algo', '123456');

-- --------------------------------------------------------
-- 2. GROUPS (3 Nhóm học tập/Nghiên cứu)
-- --------------------------------------------------------
INSERT INTO `GROUPS` (group_name, created_by) VALUES 
('Nhóm 1 - Đồ Án Web Bán Hàng', 2),
('Nhóm 2 - NCKH Nhận Diện Khuôn Mặt', 5),
('Nhóm 3 - CLB Thuật Toán OLP', 8);

-- --------------------------------------------------------
-- 3. GROUP_MEMBERS (Phân bổ sinh viên vào nhóm)
-- (Giảng viên ID 1 không vào nhóm mà chỉ đứng ngoài quản lý)
-- --------------------------------------------------------
INSERT INTO GROUP_MEMBERS (group_id, user_id, role) VALUES 
-- Nhóm Đồ án
(1, 2, 'leader'), (1, 3, 'member'), (1, 4, 'member'),
-- Nhóm NCKH
(2, 5, 'leader'), (2, 6, 'member'), (2, 7, 'member'),
-- Nhóm CLB
(3, 8, 'leader'), (3, 9, 'member'), (3, 10, 'member');

-- --------------------------------------------------------
-- 4. TASKS (Bài tập, tiểu luận, code...)
-- --------------------------------------------------------
INSERT INTO TASKS (group_id, title, description, created_by, deadline, status) VALUES 
(1, 'Báo cáo tiến độ Lần 1', 'Viết tài liệu đặc tả yêu cầu phần mềm (SRS) nộp cho thầy Giảng', 2, '2026-05-10 23:59:00', 'in_progress'),
(1, 'Thiết kế Database MySQL', 'Vẽ ERD và tạo script SQL 14 bảng', 2, '2026-05-15 23:59:00', 'todo'),
(2, 'Thu thập Dataset', 'Crawl 5000 ảnh khuôn mặt Châu Á từ Kaggle', 5, '2026-04-20 23:59:00', 'in_progress'),
(2, 'Train Model ResNet50', 'Chạy model trên Google Colab, target Accuracy > 90%', 5, '2026-05-01 23:59:00', 'todo'),
(3, 'Giải Đề OLP 2023', 'Giải 5 bài tập đồ thị và quy hoạch động', 8, '2026-04-25 12:00:00', 'in_progress');

-- --------------------------------------------------------
-- 5. TASK_ASSIGNMENTS (Giao bài cho từng sinh viên)
-- --------------------------------------------------------
INSERT INTO TASK_ASSIGNMENTS (task_id, user_id, progress, status) VALUES 
(1, 3, 60, 'in_progress'), -- Linh làm báo cáo
(2, 2, 0, 'todo'),          -- Hải vẽ DB
(3, 6, 80, 'in_progress'), -- Yến cào dữ liệu
(4, 7, 0, 'todo'),          -- Sơn train model
(5, 9, 100, 'done'),        -- Thảo giải bài OLP (Xong)
(5, 10, 40, 'in_progress'); -- Việt giải bài OLP

-- --------------------------------------------------------
-- 6. SUBTASKS (Các bước nhỏ trong bài tập)
-- --------------------------------------------------------
INSERT INTO SUBTASKS (task_id, title, status) VALUES 
(1, 'Vẽ Use Case Diagram', 'done'),
(1, 'Mô tả chi tiết Use Case', 'in_progress'),
(3, 'Tải dataset Labeled Faces in the Wild', 'done'),
(3, 'Clean data (Xóa ảnh mờ, lỗi)', 'todo');

-- --------------------------------------------------------
-- 7. TASK_PROGRESS_LOGS (Lịch sử nộp bài/cập nhật tiến độ)
-- --------------------------------------------------------
INSERT INTO TASK_PROGRESS_LOGS (assignment_id, updated_by, old_progress, new_progress, note) VALUES 
(1, 3, 0, 30, 'Đã vẽ xong Use Case bằng Draw.io, nhóm vào xem nhé.'),
(1, 3, 30, 60, 'Đang viết tài liệu đặc tả, dự kiến mai xong.'),
(5, 9, 0, 100, 'Đã AC (Accepted) cả 5 bài trên hệ thống chấm tự động.');

-- --------------------------------------------------------
-- 8. TASK_COMMENTS (Trao đổi qua lại sinh động kiểu sinh viên)
-- --------------------------------------------------------
INSERT INTO TASK_COMMENTS (task_id, user_id, content) VALUES 
(1, 2, '@Linh: Cậu nhớ thêm luồng đăng nhập bằng Google vào Use Case nhé.'),
(1, 3, 'Ok nhóm trưởng, tớ đang bổ sung rồi.'),
(1, 1, '[Giảng viên]: Các em chú ý nộp báo cáo đúng format nhà trường quy định.'),
(4, 7, 'Colab hết limit GPU rồi anh em ơi, ai còn acc share tôi mượn train nốt với!'),
(5, 10, 'Bài Quy hoạch động khó quá, Thảo gợi ý tớ công thức truy hồi với.');

-- --------------------------------------------------------
-- 9. STOCKS (Hệ thống Điểm rèn luyện/Coin Gamification)
-- --------------------------------------------------------
INSERT INTO STOCKS (user_id, group_id, stock_code, current_price) VALUES 
(2, 1, 'HAI_COIN', 110.0), (3, 1, 'LINH_COIN', 105.0), (4, 1, 'NAM_COIN', 95.0),
(5, 2, 'TUAN_COIN', 120.0), (6, 2, 'YEN_COIN', 115.0), (7, 2, 'SON_COIN', 90.0),
(8, 3, 'BACH_COIN', 100.0), (9, 3, 'THAO_COIN', 150.0), (10, 3, 'VIET_COIN', 98.0);

-- --------------------------------------------------------
-- 10. STOCK_PRICE_HISTORY (Lịch sử bị trừ/cộng điểm)
-- --------------------------------------------------------
INSERT INTO STOCK_PRICE_HISTORY (stock_id, price_before, price_after, change_reason) VALUES 
(4, 100.0, 95.0, 'Trừ điểm: Vắng họp nhóm tuần 1'),
(9, 100.0, 150.0, 'Thưởng: Giải nhanh nhất bộ đề thuật toán'),
(7, 100.0, 90.0, 'Trừ điểm: Chậm deadline báo cáo tài liệu tham khảo');

-- --------------------------------------------------------
-- 11. ACTIVITY_LOGS (Ghi nhận hoạt động)
-- --------------------------------------------------------
INSERT INTO ACTIVITY_LOGS (user_id, group_id, task_id, activity_type) VALUES 
(3, 1, 1, 'UPDATE_PROGRESS'),
(1, 1, 1, 'COMMENT_BY_TEACHER'),
(9, 3, 5, 'TASK_COMPLETED');

-- --------------------------------------------------------
-- 12. PEER_REVIEWS (Đánh giá chéo cuối kỳ)
-- --------------------------------------------------------
INSERT INTO PEER_REVIEWS (reviewer_id, reviewed_user_id, task_id, review_type, group_id, score, comment) VALUES 
(2, 3, 1, 'mid_term', 1, 9, 'Bạn Linh làm tài liệu rất cẩn thận, format đẹp, dễ đọc.'),
(4, 2, 1, 'mid_term', 1, 10, 'Leader chia việc hợp lý, gánh team khoản Backend =))'),
(5, 7, 4, 'mid_term', 2, 6, 'Bạn Sơn dạo này hay trễ deadline, cần tập trung hơn nhé.');

-- --------------------------------------------------------
-- 13. SCORING_WEIGHTS (Trọng số điểm môn học)
-- --------------------------------------------------------
INSERT INTO SCORING_WEIGHTS (component, weight) VALUES 
('DIEM_QUA_TRINH', 0.4),
('DIEM_CUOI_KY', 0.5),
('DIEM_DANH_GIA_CHEO', 0.1);

-- --------------------------------------------------------
-- 14. REWARD_PENALTY_RULES (Luật cộng trừ điểm rèn luyện)
-- --------------------------------------------------------
INSERT INTO REWARD_PENALTY_RULES (event_type, score_change, description) VALUES 
('NOP_SOM', 10, 'Nộp bài trước hạn 1 ngày được cộng 10 điểm (Coin)'),
('NOP_TRE', -20, 'Nộp muộn bị trừ 20 điểm (Coin)'),
('LEADER_THUONG', 5, 'Nhóm trưởng được cộng 5 điểm quản lý mỗi tuần');