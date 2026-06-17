Bản fix này xử lý lỗi index.jsp và projects.jsp bị trùng nhau.

Cách dùng chuẩn với backend:
1. Sau đăng nhập, nếu LoginServlet vẫn redirect index.jsp thì index.jsp sẽ tự chuyển sang MyGroupsServlet.
2. MyGroupsServlet lấy danh sách nhóm, set request.setAttribute("groups", groups), rồi forward về index.jsp.
3. projects.jsp không render giao diện nữa, chỉ redirect về MyGroupsServlet để tránh trùng Project Hub.
4. Menu ở account/faq/notifications đã đổi Trang chủ/Dự án về MyGroupsServlet.
5. Link chi tiết dự án dùng GroupDetailServlet?groupId=...

Các file nên copy vào webapp:
- index.jsp
- projects.jsp
- account.jsp
- faq.jsp
- notifications.jsp
- group_detail.jsp
- project-detail.jsp nếu backend đang forward tới file này
- assets/js/projects.js
- assets/js/project-detail.js
- assets/js/account.js
- assets/js/notifications.js
- assets/js/auth.js
- assets/css/*.css
