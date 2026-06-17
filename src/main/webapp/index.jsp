<%@ page import="model.User,model.Group,java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  User loginedUser = (User) session.getAttribute("loginedUser");
  if (loginedUser == null) { response.sendRedirect("login.jsp"); return; }
  Object groupsObj = request.getAttribute("groups");
  // Nếu người dùng vào thẳng index.jsp sau login, chuyển qua servlet để backend lấy danh sách nhóm trước.
  if (groupsObj == null) { response.sendRedirect("MyGroupsServlet"); return; }
  List<Group> groups = new ArrayList<>();
  if (groupsObj instanceof List<?>) {
    for (Object item : (List<?>) groupsObj) if (item instanceof Group) groups.add((Group)item);
  }
  String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Zero-Sum Coin Exchange | Quản lý dự án</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
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
    <div class="brand"><div class="brand-icon">ZC</div><div class="brand-text"><h2>Zero-Sum</h2><p>Coin Exchange</p></div></div>
    <nav class="menu">
      <a class="menu-item active" href="MyGroupsServlet">Trang chủ</a>
      <button class="menu-item project-menu-toggle" id="projectMenuToggle" type="button">Dự án</button>
      <div class="project-submenu" id="sidebarProjectList">
        <% for (Group g : groups) { %>
          <a href="GroupDetailServlet?groupId=<%= g.getGroupId() %>" title="<%= g.getGroupName() %>"><span><%= g.getGroupName() %></span><em>#<%= g.getGroupId() %></em></a>
        <% } %>
      </div>
      <a class="menu-item" href="notifications.jsp">Thông báo</a>
      <a class="menu-item" href="account.jsp">Tài khoản</a>
      <a class="menu-item" href="faq.jsp">FQA</a>
      <button class="menu-item logout-btn" id="logoutBtn" type="button">Đăng xuất</button>
    </nav>
    <div class="sidebar-card"><span>Workspace</span><strong>Project Hub</strong><p>Quản lý project, thành viên, task và coin hiệu suất trong một không gian thống nhất.</p></div>
  </aside>
  <main class="main-content">
    <header class="topbar"><div><p class="eyebrow">Trang chủ</p><h1>Quản lý dự án</h1></div><div class="account-box"><span>Xin chào</span><strong id="currentUserName"><%= loginedUser.getFullName()!=null?loginedUser.getFullName():loginedUser.getUsername() %></strong></div></header>
    <section class="hero-panel">
      <div><span class="tag">Zero-Sum Project Market</span><h2>Theo dõi và quản lý dự án của bạn theo cách riêng</h2><p>Biến việc làm việc nhóm trở nên thú vị và hiệu quả hơn với những ý tưởng mới.</p></div>
      <div style="display:flex;gap:12px;flex-wrap:wrap"><button class="secondary-btn" id="openJoinModal" type="button">Tham gia dự án</button><button class="primary-btn" id="openCreateModal" type="button">+ Tạo dự án mới</button></div>
    </section>
    <% if ("group_created".equals(msg)) { %><div class="panel" style="margin-bottom:16px;color:#bbf7d0">Tạo dự án/nhóm thành công.</div><% } %>
    <% if ("group_fail".equals(msg)) { %><div class="panel" style="margin-bottom:16px;color:#fecaca">Tạo dự án/nhóm thất bại.</div><% } %>
    <section class="stats-grid">
      <article class="stat-card"><span>Tổng dự án</span><strong id="totalProjects"><%= groups.size() %></strong><p>Đang được quản lý</p></article>
      <article class="stat-card"><span>Dự án đang chạy</span><strong id="activeProjects"><%= groups.size() %></strong><p class="up">Đang hoạt động</p></article>
      <article class="stat-card"><span>Tổng thành viên</span><strong id="totalMembers">--</strong><p>Các mã coin cá nhân</p></article>
      <article class="stat-card"><span>Tổng task</span><strong id="totalTasks">--</strong><p>Đã được giao</p></article>
    </section>
    <section class="panel project-panel">
      <div class="panel-header"><div><h2>Dự án của bạn</h2><p>Danh sách này do backend gửi qua request attribute <b>groups</b>.</p></div><div class="filter-group"><input id="searchProjectInput" type="text" placeholder="Tìm dự án..." /><select id="statusFilter"><option value="all">Tất cả</option><option value="active">Đang chạy</option></select></div></div>
      <div class="project-list" id="projectList" data-backend-rendered="true">
        <% for (Group g : groups) { %>
          <article class="project-card" role="button" tabindex="0" data-project-id="<%= g.getGroupId() %>">
            <div class="project-top"><div><span class="badge active">Đang chạy</span><h3><%= g.getGroupName() %></h3></div><button class="detail-link" type="button" data-project-id="<%= g.getGroupId() %>">Chi tiết</button></div>
            <p>Group ID: <b>#<%= g.getGroupId() %></b>. Nhấn chi tiết để xem dashboard, thành viên và task.</p>
            <div class="project-meta"><span>Nhóm/Dự án</span><span>ID: <%= g.getGroupId() %></span><span><%= g.getCreatedBy()==loginedUser.getUserId()?"Bạn là nhóm trưởng":"Bạn là thành viên" %></span></div>
          </article>
        <% } %>
      </div>
      <div class="empty-state" id="emptyState" style="display:<%= groups.isEmpty()?"block":"none" %>">Chưa có dự án nào. Hãy tạo dự án mới hoặc tham gia bằng Group ID.</div>
    </section>
  </main>
</div>
<div class="modal" id="projectModal" aria-hidden="true"><div class="modal-content large-modal"><button class="close-btn" id="closeModal" type="button">×</button><div class="modal-title"><span class="tag">Create Project</span><h2>Tạo dự án mới</h2><p>Backend hiện nhận tên dự án qua field <b>groupName</b>.</p></div><form id="createProjectForm" action="GroupServlet" method="post"><div class="form-group"><label for="projectName">Tên dự án *</label><input id="projectName" name="groupName" type="text" placeholder="VD: Web Tracking Behavior" required /></div><div class="modal-actions"><button class="ghost-btn" id="cancelCreateBtn" type="button">Hủy</button><button class="primary-btn" type="submit">Tạo dự án</button></div></form></div></div>
<div class="modal" id="joinModal" aria-hidden="true"><div class="modal-content"><button class="close-btn" id="closeJoinModal" type="button">×</button><div class="modal-title"><span class="tag">Join Project</span><h2>Tham gia dự án</h2><p>Nhập Group ID do nhóm trưởng cung cấp.</p></div><form id="joinProjectForm" action="JoinGroupRequestServlet" method="post"><div class="form-group"><label for="joinGroupId">Group ID *</label><input id="joinGroupId" name="groupId" type="number" min="1" placeholder="VD: 12" required /></div><div class="modal-actions"><button class="primary-btn" type="submit">Gửi yêu cầu tham gia</button></div></form></div></div>
<script src="assets/js/projects.js"></script>
</body></html>
