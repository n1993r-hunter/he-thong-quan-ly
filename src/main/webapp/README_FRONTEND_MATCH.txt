Frontend đã được chỉnh để đúng bố cục Eclipse/webapp:

webapp/
  assets/
    css/auth.css, projects.css, project-detail.css
    js/auth.js, projects.js, project-detail.js, notifications.js, account.js
  index.html        // bản auth preview tĩnh nếu cần
  login.jsp         // form đăng nhập/đăng ký/quên mật khẩu nối Servlet
  register.jsp      // mở cùng giao diện auth, tab đăng ký
  index.jsp         // trang chủ/project hub sau login
  project-detail.jsp
  group_detail.jsp  // route tương thích AddMemberServlet redirect group_detail.jsp?id=...
  notifications.jsp
  account.jsp
  faq.jsp

Các điểm đã nối với backend hiện có:
- LoginServlet: form POST action="LoginServlet", field name="username", name="password", name="remember".
- RegisterServlet: form POST action="RegisterServlet", field name="fullName", name="email", name="username", name="password".
- ForgotPasswordServlet: form POST action="ForgotPasswordServlet", field name="email", name="newPassword".
- LogoutServlet: các nút đăng xuất trên JSP chuyển tới LogoutServlet.
- GroupServlet: form tạo dự án POST action="GroupServlet", field tên dự án đổi name="groupName".
- Các trang JSP chính có kiểm tra session loginedUser để khớp backend.
- CSS/JS đã đổi đường dẫn theo assets/css và assets/js.

Lưu ý:
Backend hiện bạn gửi mới có nhóm/tài khoản cơ bản, chưa có servlet task/coin/rating/list group. Vì vậy các phần task, coin, dashboard vẫn giữ bằng JS/localStorage để không vỡ giao diện. Khi backend team có servlet/API cho task/coin thì chỉ cần đổi đoạn submit/fetch trong assets/js, không phải sửa giao diện.
