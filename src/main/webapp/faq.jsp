<%@ page import="model.User" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User loginedUser = (User) session.getAttribute("loginedUser");
  if (loginedUser == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>FQA | Zero-Sum</title><link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet"><link rel="stylesheet" href="assets/css/projects.css"></head><body>
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
</script><div class="app-shell"><aside class="sidebar"><div class="brand"><div class="brand-icon">ZC</div><div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div></div><nav class="menu"><a class="menu-item" href="MyGroupsServlet">Trang chủ</a><a class="menu-item" href="notifications.jsp">Thông báo</a><a class="menu-item" href="account.jsp">Tài khoản</a><a class="menu-item active" href="faq.jsp">FQA</a><button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button></nav><div class="sidebar-card"><span>Help Center</span><strong>FQA</strong><p>Hướng dẫn nhanh cách sử dụng hệ thống quản lý dự án Zero-Sum.</p></div></aside><main class="main-content"><header class="topbar"><div><p class="eyebrow">FQA</p><h1>Hướng dẫn sử dụng</h1></div></header><section class="hero-panel"><div><span class="tag">Zero-Sum Coin Exchange</span><h2>Quản lý dự án nhóm bằng điểm coin trực quan</h2><p class="intro-copy">Zero-Sum Coin Exchange giúp nhóm tạo dự án, giao task, theo dõi deadline, cập nhật bài làm và đánh giá đóng góp của từng thành viên. Mỗi thành viên có một mã coin riêng; khi tiến độ thay đổi, điểm coin và dashboard cũng thay đổi để nhóm dễ nhìn thấy mức độ đóng góp.</p></div></section><section class="panel"><div class="panel-header"><div><h2>Câu hỏi thường gặp</h2><p>Một số hướng dẫn nhanh khi dùng web.</p></div></div><div class="faq-grid"><div class="faq-item"><h3>1. Web này dùng để làm gì?</h3><p>Web dùng để quản lý dự án nhóm, giao nhiệm vụ, theo dõi tiến độ, cập nhật bài làm và đánh giá thành viên bằng hệ thống coin.</p></div><div class="faq-item"><h3>2. Ai là nhóm trưởng?</h3><p>Người tạo dự án được xem là nhóm trưởng. Nhóm trưởng có thể theo dõi toàn bộ task, sửa deadline và quản lý tiến độ của các thành viên.</p></div><div class="faq-item"><h3>3. Thành viên có thể làm gì?</h3><p>Thành viên có thể xem chi tiết dự án, cập nhật bài làm của chính mình, cập nhật trạng thái task được giao và đánh giá bài làm của các thành viên khác.</p></div><div class="faq-item"><h3>4. Coin được hiểu như thế nào?</h3><p>Coin là điểm mô phỏng hiệu suất. Hoàn thành task tốt có thể làm coin tăng, còn trễ deadline hoặc tiến độ xấu có thể làm coin giảm.</p></div><div class="faq-item"><h3>5. Khi nào có thông báo?</h3><p>Thông báo xuất hiện khi có cập nhật tiến độ, thay đổi deadline, đánh giá bài làm, deadline còn 1 ngày hoặc task bị trễ hạn.</p></div><div class="faq-item"><h3>6. Có thể đổi thông tin tài khoản không?</h3><p>Có. Người dùng có thể đổi ảnh đại diện, tên hiển thị, Gmail và mật khẩu nếu nhập đúng mật khẩu cũ.</p></div></div></section></main></div><script>document.getElementById('logoutBtn')?.addEventListener('click',()=>{localStorage.clear();location.href='login.jsp'})</script></body></html>
