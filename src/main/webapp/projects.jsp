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
  <title>Zero-Sum Coin Exchange | Quản lý dự án</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="assets/css/projects.css" />
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
      <div class="brand">
        <div class="brand-icon">ZC</div>
        <div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div>
      </div>

      <nav class="menu">
        <a class="menu-item active" href="index.jsp">Trang chủ</a>
        <button class="menu-item project-menu-toggle" id="projectMenuToggle" type="button">Dự án</button>
        <div class="project-submenu" id="sidebarProjectList"></div>
        <a class="menu-item" href="notifications.jsp">Thông báo</a>
        <a class="menu-item" href="account.jsp">Tài khoản</a>
        <a class="menu-item" href="faq.jsp">FQA</a>
        <button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button>
      </nav>

      <div class="sidebar-card">
        <span>Workspace</span>
        <strong>Project Hub</strong>
        <p>Quản lý project, thành viên, task và coin hiệu suất trong một không gian thống nhất.</p>
      </div>
    </aside>

    <main class="main-content">
      <header class="topbar">
        <div>
          <p class="eyebrow">Trang chủ</p>
          <h1>Quản lý dự án</h1>
        </div>
        <div class="account-box" id="account"><span>Xin chào</span><strong id="currentUserName"><%= loginedUser.getFullName() != null ? loginedUser.getFullName() : loginedUser.getUsername() %></strong></div>
      </header>

      <section class="hero-panel">
        <div>
          <span class="tag">Zero-Sum Project Market</span>
          <h2>Theo dõi và quản lý dự án của bạn theo cách riêng</h2>
          <p>Biến việc làm việc nhóm trở nên thú vị và hiệu quả hơn với những ý tưởng mới.</p>
        </div>
        <div class="modal-actions" style="margin-top:0"><button class="secondary-btn" id="openJoinModal" type="button">Tham gia dự án</button><button class="primary-btn" id="openCreateModal" type="button">+ Tạo dự án mới</button></div>
      </section>

      <section class="stats-grid">
        <article class="stat-card"><span>Tổng dự án</span><strong id="totalProjects">0</strong><p>Đang được quản lý</p></article>
        <article class="stat-card"><span>Dự án đang chạy</span><strong id="activeProjects">0</strong><p class="up">Đang hoạt động</p></article>
        <article class="stat-card"><span>Tổng thành viên</span><strong id="totalMembers">0</strong><p>Các mã coin cá nhân</p></article>
        <article class="stat-card"><span>Tổng task</span><strong id="totalTasks">0</strong><p>Đã được giao</p></article>
      </section>

      <section class="panel project-panel">
        <div class="panel-header">
          <div><h2>Dự án của bạn</h2><p>Chọn một dự án để xem dashboard, bài làm và đánh giá thành viên.</p></div>
          <div class="filter-group">
            <input id="searchProjectInput" type="text" placeholder="Tìm dự án..." />
            <select id="statusFilter">
              <option value="all">Tất cả</option>
              <option value="active">Đang chạy</option>
              <option value="warning">Có rủi ro</option>
              <option value="done">Hoàn thành</option>
            </select>
          </div>
        </div>
        <div class="project-list" id="projectList"></div>
        <div class="empty-state" id="emptyState">Chưa có dự án phù hợp.</div>
      </section>
    </main>
  </div>

  <div class="modal" id="projectModal" aria-hidden="true">
    <div class="modal-content large-modal">
      <button class="close-btn" id="closeModal" type="button">×</button>
      <div class="modal-title">
        <span class="tag">Create Project</span>
        <h2>Tạo dự án mới</h2>
        <p>Điền thông tin dự án, thêm thành viên, giao task và gán coin khởi tạo.</p>
      </div>

      <form id="createProjectForm" action="GroupServlet" method="post">
        <div class="form-grid">
          <div class="form-group"><label for="projectName">Tên dự án *</label><input id="projectName" name="groupName" type="text" placeholder="VD: Web Tracking Behavior" required /></div>
          <div class="form-group"><label for="projectDeadline">Deadline *</label><input id="projectDeadline" name="deadline" type="date" required /></div>
        </div>

        <div class="form-group"><label for="projectDesc">Mô tả dự án</label><textarea id="projectDesc" name="description" rows="3" placeholder="Mô tả ngắn mục tiêu, phạm vi hoặc yêu cầu của dự án..."></textarea></div>

        <div class="section-box">
          <div class="section-head"><div><h3>Thành viên và coin khởi tạo</h3><p>Mỗi thành viên là một mã coin trong dự án.</p></div><button class="secondary-btn" id="addMemberBtn" type="button">+ Thêm thành viên</button></div>
          <div id="memberList" class="dynamic-list"></div>
        </div>

        <div class="section-box">
          <div class="section-head"><div><h3>Task của dự án</h3><p>Giao task cho từng thành viên bằng user_id. Cột “Coin thưởng/phạt” là số coin dùng để cộng khi hoàn thành tốt hoặc trừ khi trễ hạn.</p></div><button class="secondary-btn" id="addTaskBtn" type="button">+ Thêm task</button></div>
          <div id="taskList" class="dynamic-list"></div>
        </div>

        <div class="modal-actions">
          <button class="ghost-btn" id="cancelCreateBtn" type="button">Hủy</button>
          <button class="primary-btn" type="submit">Tạo dự án</button>
        </div>
      </form>
    </div>
  </div>

  <div class="modal" id="joinProjectModal" aria-hidden="true">
    <div class="modal-content">
      <button class="close-btn" id="closeJoinModal" type="button">×</button>
      <div class="modal-title">
        <span class="tag">Join Project</span>
        <h2>Tham gia dự án đã tồn tại</h2>
        <p>Nhập Group ID do nhóm trưởng cung cấp. Yêu cầu sẽ chờ nhóm trưởng duyệt.</p>
      </div>
      <form id="joinProjectForm" action="JoinGroupRequestServlet" method="post">
        <div class="form-group">
          <label for="joinGroupId">Group ID *</label>
          <input id="joinGroupId" name="groupId" type="text" placeholder="VD: 12 hoặc 1718620000000" required />
        </div>
        <div class="modal-actions">
          <button class="ghost-btn" id="cancelJoinBtn" type="button">Hủy</button>
          <button class="primary-btn" type="submit">Gửi yêu cầu tham gia</button>
        </div>
      </form>
    </div>
  </div>

  <script src="assets/js/projects.js"></script>
</body>
</html>
