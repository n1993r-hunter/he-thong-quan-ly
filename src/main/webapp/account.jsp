<%@ page import="model.User" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User loginedUser = (User) session.getAttribute("loginedUser");
  if (loginedUser == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Tài khoản | Zero-Sum</title><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet"><link rel="stylesheet" href="assets/css/projects.css"></head><body>
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
</script><div class="app-shell"><aside class="sidebar"><div class="brand"><div class="brand-icon">ZC</div><div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div></div><nav class="menu"><a class="menu-item" href="MyGroupsServlet">Trang chủ</a><a class="menu-item" href="notifications.jsp">Thông báo</a><a class="menu-item active" href="account.jsp">Tài khoản</a><a class="menu-item" href="faq.jsp">FQA</a><button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button></nav><div class="sidebar-card"><span>User Profile</span><strong>Tài khoản</strong><p>Quản lý ảnh đại diện, tên hiển thị, email và mật khẩu đăng nhập.</p></div></aside><main class="main-content"><header class="topbar"><div><p class="eyebrow">Tài khoản</p><h1>Thông tin người dùng</h1><p class="page-desc">Cập nhật hồ sơ cá nhân theo giao diện Zero-Sum.</p></div></header><section class="profile-layout"><div class="profile-card"><div class="profile-avatar" id="avatarPreview">ZC</div><h2 id="profileName"><%= loginedUser.getFullName() != null ? loginedUser.getFullName() : loginedUser.getUsername() %></h2><p id="profileEmail"><%= loginedUser.getEmail() %></p><input id="avatarInput" type="file" accept="image/*" style="display:none"><button class="secondary-btn" id="uploadAvatarBtn" type="button" style="margin-top:18px">Tải ảnh lên</button></div><div class="panel"><div class="panel-header"><div><h2>Chỉnh sửa tài khoản</h2><p>Đổi tên, email và mật khẩu nếu nhập đúng mật khẩu cũ.</p></div></div><form class="account-form" id="accountForm"><div class="form-group"><label>Tên người dùng</label><input id="displayName" type="text" required></div><div class="form-group"><label>Gmail</label><input id="email" type="email" required></div><div class="form-grid"><div class="form-group"><label>Mật khẩu cũ</label><input id="oldPassword" type="password" placeholder="Nhập mật khẩu hiện tại"></div><div class="form-group"><label>Mật khẩu mới</label><input id="newPassword" type="password" placeholder="Ít nhất 6 ký tự"></div></div><div class="modal-actions"><button class="primary-btn" type="submit">Lưu thay đổi</button></div><p class="page-desc" id="accountMessage"></p></form></div></section></main></div><script src="assets/js/account.js"></script></body></html>
