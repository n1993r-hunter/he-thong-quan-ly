<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="model.User" %>
<%@ page import="model.Group" %>

<%!
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
%>

<%
    User loginedUser = (User) session.getAttribute("loginedUser");

    if (loginedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Object groupsObj = request.getAttribute("groups");

    if (groupsObj == null) {
        response.sendRedirect("MyGroupsServlet");
        return;
    }

    List<Group> groups = new ArrayList<>();

    if (groupsObj instanceof List<?>) {
        for (Object item : (List<?>) groupsObj) {
            if (item instanceof Group) {
                groups.add((Group) item);
            }
        }
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Zero-Sum Coin Exchange | Quản lý dự án</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/projects.css">

    <style>
        .backend-message {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 18px;
            background: rgba(56,189,248,.12);
            border: 1px solid rgba(56,189,248,.22);
            color: #bae6fd;
            font-weight: 800;
        }

        .create-form {
            display: grid;
            gap: 14px;
        }

        .project-card-backend {
            padding: 20px;
            border-radius: 24px;
            background: rgba(3,8,23,.42);
            border: 1px solid rgba(255,255,255,.10);
            transition: .24s;
        }

        .project-card-backend:hover {
            transform: translateY(-4px);
            border-color: rgba(56,189,248,.28);
            box-shadow: 0 24px 55px rgba(0,0,0,.28);
        }

        .project-card-backend h3 {
            font-size: 22px;
            margin-bottom: 10px;
        }

        .project-card-backend p {
            color: #94a3b8;
            line-height: 1.6;
            margin-bottom: 16px;
        }

        .project-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        @media(max-width: 760px) {
            .project-actions {
                flex-direction: column;
            }
        }
        .upload-form {
    display: grid;
    grid-template-columns: 1fr 220px;
    gap: 12px;
    align-items: center;
}

@media(max-width: 760px) {
    .upload-form {
        grid-template-columns: 1fr;
    }
}
    </style>
</head>

<body>
<div class="app-shell">
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-icon">ZC</div>
            <div class="brand-text">
                <h2>Zero-Sum</h2>
                <p>Coin Exchange</p>
            </div>
        </div>

        <nav class="menu">
            <a class="menu-item active" href="MyGroupsServlet">Trang chủ</a>
            <a class="menu-item" href="MyGroupsServlet">Dự án</a>
            <a class="menu-item" href="notifications.jsp">Thông báo</a>
            <a class="menu-item" href="account.jsp">Tài khoản</a>
            <a class="menu-item" href="faq.jsp">FQA</a>
            <a class="menu-item logout-btn" href="LogoutServlet">Đăng xuất</a>
        </nav>

        <div class="sidebar-card">
            <span>Workspace</span>
            <strong>Project Hub</strong>
            <p>Danh sách dự án được đọc trực tiếp từ database.</p>
        </div>
    </aside>

    <main class="main-content">
        <header class="topbar">
            <div>
                <p class="eyebrow">Trang chủ</p>
                <h1>Quản lý dự án</h1>
                <p class="page-desc">
                    Xin chào,
                    <b><%= h(loginedUser.getFullName() != null ? loginedUser.getFullName() : loginedUser.getUsername()) %></b>
                </p>
            </div>

            <div class="account-box">
                <span>Tài khoản</span>
                <strong><%= h(loginedUser.getUsername()) %></strong>
            </div>
        </header>

        <% if (msg != null) { %>
            <div class="backend-message">
                Trạng thái: <%= h(msg) %>
            </div>
        <% } %>

        <section class="hero-panel">
            <div>
                <span class="tag">Zero-Sum Project Market</span>
                <h2>Theo dõi và quản lý dự án của bạn</h2>
                <p>Dữ liệu dự án ở trang này được lấy từ MySQL thông qua GroupDAO.</p>
            </div>

            <button class="primary-btn" id="openCreateModal" type="button">
                + Tạo dự án mới
            </button>
        </section>
        
        <section class="panel" style="margin-bottom:24px;">
    <div class="panel-header">
        <div>
            <h2>Tham gia nhóm bằng Group ID</h2>
            <p>Nhập mã Group ID do nhóm trưởng gửi để yêu cầu tham gia nhóm.</p>
        </div>
    </div>

    <form action="JoinGroupRequestServlet" method="post" class="upload-form">
        <input type="number"
               name="groupId"
               placeholder="Nhập Group ID, ví dụ: 1"
               required>

        <button class="secondary-btn" type="submit">
            Gửi yêu cầu tham gia
        </button>
    </form>
</section>

        <section class="stats-grid">
            <article class="stat-card">
                <span>Tổng dự án</span>
                <strong><%= groups.size() %></strong>
                <p>Nhóm bạn đang tham gia</p>
            </article>

            <article class="stat-card">
                <span>User ID</span>
                <strong><%= loginedUser.getUserId() %></strong>
                <p>Mã người dùng</p>
            </article>

            <article class="stat-card">
                <span>Username</span>
                <strong style="font-size:24px;"><%= h(loginedUser.getUsername()) %></strong>
                <p>Tài khoản đăng nhập</p>
            </article>

            <article class="stat-card">
                <span>Email</span>
                <strong style="font-size:20px;"><%= h(loginedUser.getEmail()) %></strong>
                <p>Email người dùng</p>
            </article>
        </section>

        <section class="panel project-panel">
            <div class="panel-header">
                <div>
                    <h2>Dự án của bạn</h2>
                    <p>Bấm vào chi tiết để vào trang nhóm, tạo task, upload bài và dùng AI đánh giá.</p>
                </div>
            </div>

            <% if (groups.isEmpty()) { %>
                <div class="empty-state" style="display:block;">
                    Bạn chưa có dự án nào. Hãy tạo dự án mới.
                </div>
            <% } else { %>
                <div class="project-list">
                    <% for (Group g : groups) { %>
                        <article class="project-card-backend">
                            <span class="badge active">Đang chạy</span>
                            <h3><%= h(g.getGroupName()) %></h3>
                            <p>
                                Group ID: <b><%= g.getGroupId() %></b><br>
                                Created by User ID: <b><%= g.getCreatedBy() %></b>
                            </p>

                            <div class="project-actions">
                                <a class="primary-btn"
                                   href="GroupDetailServlet?groupId=<%= g.getGroupId() %>">
                                    Chi tiết dự án
                                </a>
                            </div>
                        </article>
                    <% } %>
                </div>
            <% } %>
        </section>
    </main>
</div>

<div class="modal" id="projectModal" aria-hidden="true">
    <div class="modal-content large-modal">
        <button class="close-btn" id="closeModal" type="button">×</button>

        <div class="modal-title">
            <span class="tag">Create Project</span>
            <h2>Tạo dự án mới</h2>
            <p>Nhập tên dự án. Sau khi tạo, hệ thống sẽ lưu vào database và tự thêm bạn làm nhóm trưởng.</p>
        </div>

        <form class="create-form" action="GroupServlet" method="post">
            <div class="form-group">
                <label for="groupName">Tên dự án *</label>
                <input id="groupName"
                       name="groupName"
                       type="text"
                       placeholder="VD: Web Tracking Behavior"
                       required>
            </div>

            <div class="modal-actions">
                <button class="ghost-btn" id="cancelCreateBtn" type="button">Hủy</button>
                <button class="primary-btn" type="submit">Tạo dự án</button>
            </div>
        </form>
    </div>
</div>

<script>
    const projectModal = document.getElementById('projectModal');
    const openCreateModal = document.getElementById('openCreateModal');
    const closeModal = document.getElementById('closeModal');
    const cancelCreateBtn = document.getElementById('cancelCreateBtn');

    openCreateModal?.addEventListener('click', function () {
        projectModal.classList.add('show');
        projectModal.setAttribute('aria-hidden', 'false');
    });

    function closeCreateModal() {
        projectModal.classList.remove('show');
        projectModal.setAttribute('aria-hidden', 'true');
    }

    closeModal?.addEventListener('click', closeCreateModal);
    cancelCreateBtn?.addEventListener('click', closeCreateModal);

    projectModal?.addEventListener('click', function (event) {
        if (event.target === projectModal) {
            closeCreateModal();
        }
    });
</script>
</body>
</html>