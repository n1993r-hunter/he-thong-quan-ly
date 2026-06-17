<%@ page import="model.User" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User loginedUser = (User) session.getAttribute("loginedUser");
  if (loginedUser == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Zero-Sum Coin Exchange | Chi tiết dự án</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="assets/css/project-detail.css" />
</head>
<body>
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
</script>
  <div class="app-shell">
    <aside class="sidebar">
      <div class="brand"><div class="brand-icon">ZC</div><div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div></div>
      <nav class="menu">
        <a class="menu-item" href="index.jsp">Trang chủ</a>
        <button class="menu-item project-menu-toggle active" id="projectMenuToggle" type="button">Dự án</button>
        <div class="project-submenu" id="sidebarProjectList"></div>
        <a class="menu-item" href="notifications.jsp">Thông báo</a>
        <a class="menu-item" href="account.jsp">Tài khoản</a>
        <a class="menu-item" href="faq.jsp">FQA</a>
        <button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button>
      </nav>
      <div class="sidebar-card"><span>Current project</span><strong id="sidebarProjectCode">PROJECT</strong><p id="roleNote">Theo dõi coin, bài làm và đánh giá đóng góp của từng thành viên.</p></div>
    </aside>

    <main class="main-content" id="detail">
      <header class="topbar">
        <div><p class="eyebrow">Tên dự án</p><h1 id="projectName">Tên dự án</h1><p class="page-desc" id="projectDesc">Mô tả dự án</p></div>
        <div class="account-box" id="account"><span>Xin chào</span><strong id="currentUserName"><%= loginedUser.getFullName() != null ? loginedUser.getFullName() : loginedUser.getUsername() %></strong><em id="currentUserRole">Member</em></div>
      </header>

      <section class="project-summary">
        <article><span>Project index</span><strong id="marketIndex">0.00</strong><p id="marketChange" class="up">▲ 0.00%</p></article>
        <article><span>Thành viên</span><strong id="memberCount">0</strong><p>Mã coin cá nhân</p></article>
        <article><span>Tổng task</span><strong id="taskCount">0</strong><p>Đang theo dõi</p></article>
        <article><span>Deadline</span><strong id="deadlineText">--</strong><p>Ngày kết thúc</p></article>
      </section>

      <section class="panel" id="groupAccessPanel">
        <div class="panel-header">
          <div>
            <h2>Group ID & quản lý thành viên</h2>
            <p>Group ID dùng để mời thành viên tham gia. Nhóm trưởng có thể duyệt yêu cầu và kick thành viên khỏi dự án.</p>
          </div>
          <div class="modal-actions" style="margin-top:0">
            <button class="secondary-btn" id="copyGroupIdBtn" type="button">Copy Group ID</button>
          </div>
        </div>
        <div class="stats-grid" style="margin-bottom:0">
          <article class="stat-card"><span>Group ID</span><strong id="groupIdText">--</strong><p>Gửi mã này cho người muốn tham gia</p></article>
          <article class="stat-card"><span>Chờ duyệt</span><strong id="pendingCount">0</strong><p>Yêu cầu tham gia nhóm</p></article>
        </div>
        <div class="notice-grid" id="pendingRequestList" style="margin-top:16px"></div>
      </section>

      <section class="panel chart-panel">
        <div class="panel-header"><div><h2>Dashboard tiến độ coin</h2><p>Theo dõi biến động coin của từng thành viên theo thời gian.</p></div><button class="secondary-btn" id="simulateMarketBtn" type="button">Cập nhật tiến độ</button></div>
        <div class="chart-wrap"><canvas id="coinChart" width="1200" height="460" aria-label="Biểu đồ coin theo thời gian"></canvas></div>
        <div class="legend" id="chartLegend"></div>
      </section>

      <section class="panel board-panel">
        <div class="panel-header small"><div><h2>Bảng coin thành viên</h2><p>Tổng quan giá trị coin và thay đổi phiên gần nhất.</p></div></div>
        <div class="market-board-grid" id="marketBoard"></div>
      </section>

      <section class="panel" id="members">
        <div class="panel-header"><div><h2>Thành viên & bài làm</h2><p>Thành viên cập nhật bài của mình; mọi người đều xem và đánh giá bài làm của nhau.</p></div></div>
        <div class="member-grid" id="memberGrid"></div>
      </section>
    </main>
  </div>

  <div class="modal" id="taskModal" aria-hidden="true">
    <div class="modal-content large-modal">
      <button class="close-btn" id="closeTaskModal" type="button">×</button>
      <div class="modal-title"><span class="tag">Task Detail</span><h2 id="modalMemberName">Chi tiết thành viên</h2><p id="modalMemberMeta">Xem chi tiết bài làm và đánh giá đóng góp.</p></div>
      <div class="score-note"><strong>Thang đánh giá:</strong><span>1⭐ Tệ, cần làm lại</span><span>2⭐ Cần chỉnh sửa</span><span>3⭐ Đạt yêu cầu</span><span>4⭐ Tốt</span><span>5⭐ Xuất sắc</span></div>
      <div class="table-wrap"><table><thead><tr><th>Task</th><th>Deadline</th><th>Trạng thái</th><th>Bài làm / cập nhật</th><th>Đánh giá</th></tr></thead><tbody id="modalTaskBody"></tbody></table></div>
      <div class="modal-actions"><button class="primary-btn" id="saveTaskUpdates" type="button">Lưu cập nhật</button></div>
    </div>
  </div>

  <script src="assets/js/project-detail.js"></script>
</body>
</html>
