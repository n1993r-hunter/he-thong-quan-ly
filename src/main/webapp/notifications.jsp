<%@ page import="model.User" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User loginedUser = (User) session.getAttribute("loginedUser");
  if (loginedUser == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Thông báo | Zero-Sum</title><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet"><link rel="stylesheet" href="assets/css/projects.css"></head><body>
<script>
  window.ZC_BACKEND_USER = {
    id: "<%= loginedUser.getUserId() %>",
    fullName: "<%= loginedUser.getFullName() == null ? "" : loginedUser.getFullName().replace("\\", "\\\\").replace("\"", "\\\"") %>",
    email: "<%= loginedUser.getEmail() == null ? "" : loginedUser.getEmail().replace("\\", "\\\\").replace("\"", "\\\"") %>",
    username: "<%= loginedUser.getUsername() == null ? "" : loginedUser.getUsername().replace("\\", "\\\\").replace("\"", "\\\"") %>"
  };
  localStorage.setItem("zc_logged_in", "true");
  localStorage.setItem("zc_user_id", window.ZC_BACKEND_USER.id);
  localStorage.setItem("zc_user_name", window.ZC_BACKEND_USER.fullName || window.ZC_BACKEND_USER.username || "Team Member");
  localStorage.setItem("zc_user_email", window.ZC_BACKEND_USER.email || "");
</script><div class="app-shell"><aside class="sidebar"><div class="brand"><div class="brand-icon">ZC</div><div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div></div><nav class="menu"><a class="menu-item" href="MyGroupsServlet">Trang chủ</a><a class="menu-item" href="MyGroupsServlet">Dự án</a><a class="menu-item active" href="notifications.jsp">Thông báo</a><a class="menu-item" href="account.jsp">Tài khoản</a><a class="menu-item" href="faq.jsp">FQA</a><button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button></nav><div class="sidebar-card"><span>Notification Center</span><strong>Cập nhật</strong><p>Theo dõi deadline, đánh giá, thay đổi tiến độ và cảnh báo trễ hạn.</p></div></aside><main class="main-content"><header class="topbar"><div><p class="eyebrow">Thông báo</p><h1>Trung tâm thông báo</h1><p class="page-desc">Các thay đổi quan trọng trong dự án sẽ được tổng hợp tại đây.</p></div></header><section class="stats-grid"><article class="stat-card"><span>Tất cả</span><strong id="noticeTotal">0</strong><p>Thông báo</p></article><article class="stat-card"><span>Sắp đến hạn</span><strong id="noticeDue">0</strong><p class="up">Báo trước 1 ngày</p></article><article class="stat-card"><span>Update</span><strong id="noticeUpdate">0</strong><p>Cập nhật mới</p></article><article class="stat-card"><span>Nghiêm trọng</span><strong id="noticeDanger">0</strong><p class="down">Trễ deadline</p></article></section><section class="panel"><div class="panel-header"><div><h2>Thông báo dự án</h2><p>Cảnh báo deadline, cập nhật tiến độ và đánh giá bài làm.</p></div></div><div class="notice-grid" id="noticeList"></div><div class="empty-state" id="emptyState">Chưa có thông báo nào.</div></section></main></div><script src="assets/js/notifications.js"></script></body></html>
