Bản fix frontend:
1) Xóa project mẫu: user mới vào sẽ thấy danh sách trống.
2) Trang chủ có nút "Tham gia dự án" cạnh "Tạo dự án mới".
3) Form tham gia dự án gửi groupId tới JoinGroupRequestServlet khi chạy JSP/Tomcat.
4) Trang chi tiết hiển thị Group ID + nút Copy Group ID.
5) Nhóm trưởng có khu vực duyệt yêu cầu tham gia và nút kick thành viên.
6) Sửa lỗi projects.js bị lặp submit/dư dấu });.
7) Sửa account.js và notifications.js bị lỗi IS_JSP_PAGE chưa khai báo.
8) Sửa auth.js để không set localStorage đăng nhập giả khi chạy JSP.

Các file nên thay:
- projects.html / projects.jsp
- project-detail.html / project-detail.jsp / group_detail.jsp nếu bạn đang dùng file này
- assets/js/projects.js
- assets/js/project-detail.js
- assets/js/auth.js
- assets/js/account.js
- assets/js/notifications.js
- assets/css/project-detail.css
