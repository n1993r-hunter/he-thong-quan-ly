<%@ page import="model.PeerReviewView" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.JoinRequestView" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="model.User" %>
<%@ page import="model.MemberStock" %>
<%@ page import="model.TaskSubmissionView" %>
<%@ page import="model.LeaderReviewView" %>
<%@ page import="model.StockHistoryView" %>

<%!
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String fmt(Object value) {
        if (value == null) return "--";
        if (value instanceof Timestamp) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format((Timestamp) value);
        }
        return h(value);
    }

    private String stars(Integer star) {
        if (star == null || star <= 0) return "Chưa chấm";
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            sb.append(i <= star ? "★" : "☆");
        }
        return sb.toString();
    }
    private int peerReviewCount(List<PeerReviewView> reviews, int taskId, int reviewedUserId) {
        int count = 0;

        if (reviews == null) {
            return 0;
        }

        for (PeerReviewView review : reviews) {
            if (review.getTaskId() != null
                    && review.getTaskId().intValue() == taskId
                    && review.getReviewedUserId() == reviewedUserId) {
                count++;
            }
        }

        return count;
    }

    private double peerReviewAverage(List<PeerReviewView> reviews, int taskId, int reviewedUserId) {
        int count = 0;
        int total = 0;

        if (reviews == null) {
            return 0;
        }

        for (PeerReviewView review : reviews) {
            if (review.getTaskId() != null
                    && review.getTaskId().intValue() == taskId
                    && review.getReviewedUserId() == reviewedUserId) {
                total += review.getStar();
                count++;
            }
        }

        if (count == 0) {
            return 0;
        }

        return Math.round((total * 10.0 / count)) / 10.0;
    }

    private PeerReviewView myPeerReview(List<PeerReviewView> reviews, int taskId, int reviewedUserId, int currentUserId) {
        if (reviews == null) {
            return null;
        }

        for (PeerReviewView review : reviews) {
            if (review.getTaskId() != null
                    && review.getTaskId().intValue() == taskId
                    && review.getReviewedUserId() == reviewedUserId
                    && review.getReviewerId() == currentUserId) {
                return review;
            }
        }

        return null;
    }
    
    private LeaderReviewView leaderReviewOf(List<LeaderReviewView> reviews, int taskId, int reviewedUserId) {
        if (reviews == null) {
            return null;
        }

        for (LeaderReviewView review : reviews) {
            if (review.getTaskId() != null
                    && review.getTaskId().intValue() == taskId
                    && review.getReviewedUserId() == reviewedUserId) {
                return review;
            }
        }

        return null;
    }
    
    private String js(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\"", "\\\"")
                .replace("\r", " ")
                .replace("\n", " ");
    }
%>

<%
    User loginedUser = (User) session.getAttribute("loginedUser");

    if (loginedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer groupId = (Integer) request.getAttribute("groupId");

    if (groupId == null) {
        String rawGroupId = request.getParameter("groupId");
        if (rawGroupId == null || rawGroupId.trim().isEmpty()) {
            rawGroupId = request.getParameter("id");
        }

        if (rawGroupId != null && !rawGroupId.trim().isEmpty()) {
            response.sendRedirect("GroupDetailServlet?groupId=" + rawGroupId);
            return;
        }

        response.sendRedirect("MyGroupsServlet");
        return;
    }

    String groupName = (String) request.getAttribute("groupName");

    List<MemberStock> members = new ArrayList<>();
    Object membersObj = request.getAttribute("members");

    if (membersObj instanceof List<?>) {
        for (Object item : (List<?>) membersObj) {
            if (item instanceof MemberStock) {
                members.add((MemberStock) item);
            }
        }
    }
    
    List<StockHistoryView> stockHistories = new ArrayList<>();
    Object stockHistoriesObj = request.getAttribute("stockHistories");

    if (stockHistoriesObj instanceof List<?>) {
        for (Object item : (List<?>) stockHistoriesObj) {
            if (item instanceof StockHistoryView) {
                stockHistories.add((StockHistoryView) item);
            }
        }
    }

    List<TaskSubmissionView> taskViews = new ArrayList<>();
    Object taskViewsObj = request.getAttribute("taskViews");

    if (taskViewsObj instanceof List<?>) {
        for (Object item : (List<?>) taskViewsObj) {
            if (item instanceof TaskSubmissionView) {
                taskViews.add((TaskSubmissionView) item);
            }
        }
    }
    
    List<JoinRequestView> pendingRequests = new ArrayList<>();
    Object pendingRequestsObj = request.getAttribute("pendingRequests");

    if (pendingRequestsObj instanceof List<?>) {
        for (Object item : (List<?>) pendingRequestsObj) {
            if (item instanceof JoinRequestView) {
                pendingRequests.add((JoinRequestView) item);
            }
        }
    }
    List<PeerReviewView> peerReviews = new ArrayList<>();
    Object peerReviewsObj = request.getAttribute("peerReviews");

    if (peerReviewsObj instanceof List<?>) {
        for (Object item : (List<?>) peerReviewsObj) {
            if (item instanceof PeerReviewView) {
                peerReviews.add((PeerReviewView) item);
            }
        }
    }
    
    List<LeaderReviewView> leaderReviews = new ArrayList<>();
    Object leaderReviewsObj = request.getAttribute("leaderReviews");

    if (leaderReviewsObj instanceof List<?>) {
        for (Object item : (List<?>) leaderReviewsObj) {
            if (item instanceof LeaderReviewView) {
                leaderReviews.add((LeaderReviewView) item);
            }
        }
    }

    Boolean isLeaderObj = (Boolean) request.getAttribute("isLeader");
    boolean isLeader = isLeaderObj != null && isLeaderObj;

    int currentUserId = loginedUser.getUserId();

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết nhóm | Zero-Sum</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/project-detail.css">

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

        .task-create-form {
            display: grid;
            gap: 14px;
        }

        .task-create-grid {
            display: grid;
            grid-template-columns: 1fr 220px 220px;
            gap: 14px;
        }

        .task-card-list {
            display: grid;
            gap: 16px;
        }

        .task-card-backend {
            padding: 20px;
            border-radius: 22px;
            background: linear-gradient(145deg, rgba(15,23,42,.88), rgba(7,13,27,.94));
            border: 1px solid rgba(255,255,255,.1);
        }

        .task-card-head {
            display: flex;
            justify-content: space-between;
            gap: 18px;
            align-items: flex-start;
            margin-bottom: 14px;
        }

        .task-card-head h3 {
            font-size: 21px;
            margin-bottom: 8px;
        }

        .task-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            color: #94a3b8;
            font-size: 13px;
            margin-top: 10px;
        }

        .task-meta span {
            padding: 7px 10px;
            border-radius: 999px;
            background: rgba(255,255,255,.05);
            border: 1px solid rgba(255,255,255,.06);
        }

        .submission-box {
            margin-top: 16px;
            padding: 16px;
            border-radius: 18px;
            background: rgba(3,8,23,.42);
            border: 1px solid rgba(255,255,255,.08);
        }

        .submission-box h4 {
            margin-bottom: 10px;
            color: #fff;
        }

        .upload-form {
            display: grid;
            grid-template-columns: 1fr 180px;
            gap: 12px;
            align-items: center;
            margin-top: 12px;
        }

        .ai-result-card {
            margin-top: 14px;
            padding: 16px;
            border-radius: 18px;
            background: rgba(34,197,94,.08);
            border: 1px solid rgba(34,197,94,.18);
        }

        .ai-result-card h4 {
            margin-bottom: 10px;
            color: #bbf7d0;
        }

        .ai-result-card p {
            color: #cbd5e1;
            line-height: 1.65;
            margin-top: 8px;
        }

        .ai-star {
            color: #facc15;
            font-size: 20px;
            font-weight: 900;
        }

        .small-muted {
            color: #94a3b8;
            font-size: 13px;
            line-height: 1.6;
        }

        @media(max-width: 900px) {
            .task-create-grid,
            .upload-form {
                grid-template-columns: 1fr;
            }

            .task-card-head {
                flex-direction: column;
            }
        }
        .member-filter-bar {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 18px 0 22px;
}

.member-filter-btn {
    border: 1px solid rgba(255,255,255,.12);
    background: rgba(15,23,42,.9);
    color: #cbd5e1;
    padding: 10px 14px;
    border-radius: 999px;
    cursor: pointer;
    font-weight: 800;
    transition: .2s ease;
}

.member-filter-btn:hover {
    border-color: rgba(56,189,248,.5);
    color: #e0f2fe;
}

.member-filter-btn.active {
    background: linear-gradient(135deg, #38bdf8, #6366f1);
    color: white;
    border-color: transparent;
}

.task-compact-summary {
    display: grid;
    grid-template-columns: repeat(5, minmax(130px, 1fr));
    gap: 10px;
    margin-top: 14px;
}

.task-compact-summary span {
    padding: 10px 12px;
    border-radius: 14px;
    background: rgba(255,255,255,.05);
    border: 1px solid rgba(255,255,255,.07);
    color: #cbd5e1;
    font-size: 13px;
}

.task-compact-summary b {
    display: block;
    color: #fff;
    font-size: 15px;
    margin-top: 4px;
}

.review-details {
    margin-top: 14px;
    border-radius: 18px;
    background: rgba(3,8,23,.36);
    border: 1px solid rgba(255,255,255,.08);
    overflow: hidden;
}

.review-details summary {
    cursor: pointer;
    padding: 14px 16px;
    font-weight: 900;
    color: #e2e8f0;
    list-style: none;
}

.review-details summary::-webkit-details-marker {
    display: none;
}

.review-details summary::after {
    content: "Mở";
    float: right;
    color: #38bdf8;
    font-size: 13px;
}

.review-details[open] summary::after {
    content: "Đóng";
}

.review-details-body {
    padding: 0 16px 16px;
}
.stock-chart-panel {
    margin-top: 20px;
}

.stock-chart-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    margin-bottom: 18px;
}

.stock-chart-toolbar select {
    min-width: 260px;
}

.stock-chart-box {
    padding: 18px;
    border-radius: 22px;
    background: rgba(3,8,23,.42);
    border: 1px solid rgba(255,255,255,.08);
}

#stockChartCanvas {
    width: 100%;
    height: 340px;
    display: block;
}

.stock-chart-info {
    margin-top: 14px;
    color: #cbd5e1;
    font-size: 14px;
    line-height: 1.7;
}

.stock-history-list {
    margin-top: 18px;
    display: grid;
    gap: 10px;
}

.stock-history-item {
    padding: 12px 14px;
    border-radius: 16px;
    background: rgba(255,255,255,.05);
    border: 1px solid rgba(255,255,255,.07);
    color: #cbd5e1;
    font-size: 13px;
}
.stock-chart-legend {
    display: flex;
    flex-wrap: wrap;
    gap: 10px 16px;
    margin-top: 14px;
    margin-bottom: 8px;
}

.stock-chart-legend-item {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #cbd5e1;
    font-size: 13px;
}

.stock-chart-legend-color {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    display: inline-block;
}
.coin-ranking-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 14px;
    overflow: hidden;
    border-radius: 18px;
}

.coin-ranking-table th,
.coin-ranking-table td {
    padding: 14px 12px;
    border-bottom: 1px solid rgba(255,255,255,.08);
    color: #cbd5e1;
    text-align: left;
}

.coin-ranking-table th {
    color: #fff;
    background: rgba(15,23,42,.86);
    font-weight: 900;
}

.coin-ranking-table tr {
    background: rgba(3,8,23,.36);
}

.coin-ranking-table tr:hover {
    background: rgba(56,189,248,.08);
}

.rank-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 34px;
    height: 34px;
    border-radius: 999px;
    background: rgba(56,189,248,.16);
    border: 1px solid rgba(56,189,248,.28);
    color: #e0f2fe;
    font-weight: 900;
}

.coin-up {
    color: #86efac;
    font-weight: 900;
}

.coin-down {
    color: #fca5a5;
    font-weight: 900;
}

.coin-equal {
    color: #fde68a;
    font-weight: 900;
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
            <a class="menu-item" href="index.jsp">Trang chủ</a>
            <a class="menu-item" href="notifications.jsp">Thông báo</a>
            <a class="menu-item" href="account.jsp">Tài khoản</a>
            <a class="menu-item" href="faq.jsp">FQA</a>
            <a class="menu-item logout-btn" href="LogoutServlet">Đăng xuất</a>
        </nav>

        <div class="sidebar-card">
            <span>Current Group</span>
            <strong>GROUP #<%= groupId %></strong>
            <p>Theo dõi task, bài nộp và kết quả AI của từng thành viên.</p>
        </div>
    </aside>

    <main class="main-content">
        <header class="topbar">
        <% if (isLeader) { %>
    <section class="panel" style="margin-bottom:20px; border-color:rgba(239,68,68,.35);">
        <div class="panel-header">
            <div>
                <h2 style="color:#fecaca;">Khu vực nguy hiểm</h2>
                <p>
                    Giải thể nhóm sẽ xóa toàn bộ dữ liệu của nhóm này, bao gồm task, bài nộp,
                    đánh giá AI, peer review, leader review, coin và lịch sử biến động coin.
                </p>
            </div>
        </div>

        <form action="DissolveGroupServlet"
              method="post"
              onsubmit="return confirm('Bạn chắc chắn muốn GIẢI THỂ nhóm này? Toàn bộ dữ liệu nhóm sẽ bị xóa và không thể khôi phục.');">

            <input type="hidden" name="groupId" value="<%= groupId %>">

            <button type="submit"
                    class="ghost-btn"
                    style="border-color:rgba(239,68,68,.55); color:#fecaca;">
                Giải thể nhóm
            </button>
        </form>
    </section>
<% } %>
            <div>
                <p class="eyebrow">Chi tiết nhóm</p>
                <h1><%= h(groupName) %></h1>
                <p class="page-desc">
                    Group ID: <b><%= groupId %></b> ·
                    Vai trò của bạn:
                    <b><%= isLeader ? "Nhóm trưởng" : "Thành viên" %></b>
                </p>
            </div>

            <div class="account-box">
                <span>Xin chào</span>
                <strong><%= h(loginedUser.getFullName() != null ? loginedUser.getFullName() : loginedUser.getUsername()) %></strong>
                <em><%= isLeader ? "Leader" : "Member" %></em>
            </div>
        </header>

        <% if (msg != null) { %>
            <div class="backend-message">
                Trạng thái: <%= h(msg) %>
            </div>
        <% } %>

        <section class="project-summary">
            <article>
                <span>Group ID</span>
                <strong><%= groupId %></strong>
                <p>Mã nhóm</p>
            </article>

            <article>
                <span>Thành viên</span>
                <strong><%= members.size() %></strong>
                <p>Mã coin cá nhân</p>
            </article>

            <article>
                <span>Task đã giao</span>
                <strong><%= taskViews.size() %></strong>
                <p>Task assignments</p>
            </article>

            <article>
                <span>Quyền</span>
                <strong><%= isLeader ? "Leader" : "Member" %></strong>
                <p>Vai trò hiện tại</p>
            </article>
        </section>
        
       <% if (isLeader) { %>
<section class="panel" style="margin-top:20px;">
    <div class="panel-header">
        <div>
            <h2>Xếp hạng coin tại một thời điểm</h2>
            <p>
                Nhóm trưởng nhập một thời điểm bất kỳ để xem thứ tự coin của thành viên tại đúng thời điểm đó.
            </p>
        </div>
    </div>

    <form id="coinRankingForm" class="task-create-form">
        <input type="hidden" name="groupId" value="<%= groupId %>">

        <div class="task-create-grid" style="grid-template-columns:1fr 220px;">
            <div class="form-group">
                <label>Thời điểm cần xem</label>
                <input type="datetime-local" name="queryTime">
            </div>

            <div class="form-group">
                <label>&nbsp;</label>
                <button type="submit" class="primary-btn">
                    Xem xếp hạng coin
                </button>
            </div>
        </div>
    </form>

    <div id="coinRankingResult" style="margin-top:18px;">
        <p class="small-muted">
            Chọn một thời điểm rồi bấm xem xếp hạng.
            Nếu bỏ trống thời điểm, hệ thống sẽ hiển thị xếp hạng coin hiện tại.
        </p>
    </div>
</section>
<% } %>
        
        <section class="panel stock-chart-panel">
    <div class="panel-header">
        <div>
            <h2>Biểu đồ biến động coin</h2>
            <p>Theo dõi giá coin hiện tại và lịch sử thay đổi sau AI Review, Peer Review, Leader Review.</p>
        </div>
    </div>

    <div class="stock-chart-toolbar">
        <select id="stockChartMemberSelect">
            <option value="all">Tất cả thành viên - Giá hiện tại</option>

            <% for (MemberStock m : members) { %>
                <option value="<%= m.getUserId() %>">
                    <%= h(m.getFullName()) %> (@<%= h(m.getUsername()) %>)
                </option>
            <% } %>
        </select>

        <button type="button" class="secondary-btn" id="refreshStockChartBtn">
            Cập nhật biểu đồ
        </button>
    </div>

    <div class="stock-chart-box">
    <canvas id="stockChartCanvas" width="900" height="340"></canvas>

    <div id="stockChartLegend" class="stock-chart-legend"></div>

    <div id="stockChartInfo" class="stock-chart-info">
        Đang tải biểu đồ...
    </div>

    <div id="stockHistoryList" class="stock-history-list"></div>
</div>
</section>

        <section class="panel board-panel">
    <div class="panel-header small">
        <div>
            <h2>Thành viên nhóm</h2>
            <p>Nhóm trưởng có thể thêm thành viên bằng username và xóa thành viên khỏi nhóm.</p>
        </div>
    </div>

    <% if (isLeader) { %>
        <div class="submission-box" style="margin-bottom:18px;">
            <h4>Thêm thành viên vào nhóm</h4>

            <form action="AddMemberServlet" method="post" class="upload-form">
                <input type="hidden" name="groupId" value="<%= groupId %>">

                <input type="text"
                       name="username"
                       placeholder="Nhập username thành viên cần thêm"
                       required>

                <button class="primary-btn" type="submit">
                    + Thêm thành viên
                </button>
            </form>

            <p class="small-muted" style="margin-top:10px;">
                Thành viên phải có tài khoản trong bảng USERS trước thì mới thêm được.
            </p>
        </div>
    <% } %>

    <div class="market-board-grid">
        <% for (MemberStock m : members) { %>
            <div class="board-row" style="align-items:flex-start;">
                <div>
                    <div class="board-code"><%= h(m.getStockCode()) %></div>

                    <div class="board-name">
                        <%= h(m.getFullName()) %>
                        (@<%= h(m.getUsername()) %>)

                        <% if ("leader".equalsIgnoreCase(m.getRole())) { %>
                            · Nhóm trưởng
                        <% } else { %>
                            · Thành viên
                        <% } %>
                    </div>

                    <div class="small-muted" style="margin-top:8px;">
                        User ID: <%= m.getUserId() %><br>
                        Role: <%= h(m.getRole()) %>
                    </div>
                </div>

                <div style="text-align:right;">
                    <div class="board-price"><%= m.getCurrentPrice() %></div>
                    <div class="small-muted">COIN</div>

                    <% if (isLeader && !"leader".equalsIgnoreCase(m.getRole()) && m.getUserId() != currentUserId) { %>
                        <form action="KickMemberServlet"
                              method="post"
                              style="margin-top:12px;"
                              onsubmit="return confirm('Bạn chắc chắn muốn xóa thành viên này khỏi nhóm?');">

                            <input type="hidden" name="groupId" value="<%= groupId %>">
                            <input type="hidden" name="userId" value="<%= m.getUserId() %>">

                            <button class="ghost-btn" type="submit">
                                Xóa thành viên
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>
        <% } %>
    </div>
</section>
<section class="panel" style="margin-top:20px;">
    <div class="panel-header">
        <div>
            <h2>Yêu cầu gia nhập nhóm</h2>
            <p>Thành viên khác có thể nhập Group ID để gửi yêu cầu tham gia. Nhóm trưởng có quyền duyệt hoặc từ chối.</p>
        </div>
    </div>

    <div class="stats-grid" style="margin-bottom:18px;">
        <article class="stat-card">
            <span>Group ID</span>
            <strong><%= groupId %></strong>
            <p>Gửi mã này cho thành viên muốn tham gia</p>
        </article>

        <article class="stat-card">
            <span>Yêu cầu chờ duyệt</span>
            <strong><%= pendingRequests.size() %></strong>
            <p>Pending requests</p>
        </article>
    </div>

    <% if (!isLeader) { %>
        <div class="submission-box">
            <h4>Chỉ nhóm trưởng được duyệt yêu cầu</h4>
            <p class="small-muted">
                Bạn có thể xem Group ID để gửi cho người khác, nhưng không thể duyệt hoặc từ chối yêu cầu.
            </p>
        </div>
    <% } else { %>

        <% if (pendingRequests.isEmpty()) { %>
            <div class="submission-box">
                <h4>Không có yêu cầu chờ duyệt</h4>
                <p class="small-muted">
                    Khi có người gửi yêu cầu tham gia nhóm, danh sách sẽ hiện ở đây.
                </p>
            </div>
        <% } else { %>
            <div class="task-card-list">
                <% for (JoinRequestView req : pendingRequests) { %>
                    <article class="task-card-backend">
                        <div class="task-card-head">
                            <div>
                                <h3><%= h(req.getFullName()) %></h3>

                                <div class="task-meta">
                                    <span>Request ID: <%= req.getRequestId() %></span>
                                    <span>User ID: <%= req.getUserId() %></span>
                                    <span>Username: <%= h(req.getUsername()) %></span>
                                    <span>Email: <%= h(req.getEmail()) %></span>
                                    <span>Gửi lúc: <%= fmt(req.getRequestedAt()) %></span>
                                </div>
                            </div>
                        </div>

                        <div class="project-actions" style="margin-top:14px;">
                            <form action="ReviewJoinRequestServlet" method="post" style="display:inline;">
                                <input type="hidden" name="groupId" value="<%= groupId %>">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <input type="hidden" name="action" value="approve">

                                <button class="primary-btn" type="submit">
                                    Duyệt
                                </button>
                            </form>

                            <form action="ReviewJoinRequestServlet"
                                  method="post"
                                  style="display:inline;"
                                  onsubmit="return confirm('Bạn chắc chắn muốn từ chối yêu cầu này?');">

                                <input type="hidden" name="groupId" value="<%= groupId %>">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <input type="hidden" name="action" value="reject">

                                <button class="ghost-btn" type="submit">
                                    Từ chối
                                </button>
                            </form>
                        </div>
                    </article>
                <% } %>
            </div>
        <% } %>

    <% } %>
</section>

        <% if (isLeader) { %>
            <section class="panel">
                <div class="panel-header">
                    <div>
                        <h2>Tạo task và giao cho thành viên</h2>
                        <p>Nhóm trưởng tạo task, chọn người thực hiện, sau đó thành viên upload file bài làm.</p>
                    </div>
                </div>

                <form class="task-create-form" action="CreateTaskServlet" method="post">
                    <input type="hidden" name="groupId" value="<%= groupId %>">

                    <div class="task-create-grid">
                        <div class="form-group">
                            <label>Tên task</label>
                            <input type="text" name="title" placeholder="VD: Làm chức năng upload file" required>
                        </div>

                        <div class="form-group">
                            <label>Deadline</label>
                            <input type="datetime-local" name="deadline" required>
                        </div>

                        <div class="form-group">
                            <label>Giao cho</label>
                            <select name="assigneeId" required>
                                <% for (MemberStock m : members) { %>
                                    <option value="<%= m.getUserId() %>">
                                        <%= h(m.getFullName()) %> (@<%= h(m.getUsername()) %>)
                                    </option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Mô tả task / tiêu chí chấm</label>
                        <textarea name="description" rows="4" placeholder="Nhập yêu cầu task để AI dựa vào đây đánh giá bài nộp..."></textarea>
                    </div>

                    <div class="modal-actions">
                        <button class="primary-btn" type="submit">Tạo và giao task</button>
                    </div>
                </form>
            </section>
        <% } %>

        <section class="panel" style="margin-top: 20px;">
    <div class="panel-header">
        <div>
            <h2>Task theo thành viên</h2>
            <p>Chọn thành viên để xem bài làm, peer review và AI review của người đó.</p>
        </div>
    </div>

    <div class="member-filter-bar">
        <button type="button" class="member-filter-btn active" data-member-filter="all">
            Tất cả
        </button>

        <button type="button" class="member-filter-btn" data-member-filter="<%= currentUserId %>">
            Bài của tôi
        </button>

        <% for (MemberStock m : members) { %>
            <button type="button" class="member-filter-btn" data-member-filter="<%= m.getUserId() %>">
                <%= h(m.getFullName()) %>
            </button>
        <% } %>
    </div>

    <% if (taskViews.isEmpty()) { %>
        <div class="empty-state" style="display:block;">
            Chưa có task nào được giao trong nhóm này.
        </div>
    <% } else { %>

        <div id="filterEmptyState" class="empty-state" style="display:none;">
            Thành viên này chưa có task nào.
        </div>

        <div class="task-card-list">
            <% for (TaskSubmissionView t : taskViews) {
                boolean canUpload = t.getAssigneeUserId() == currentUserId;
                boolean canEvaluate = t.getSubmissionId() != null && (canUpload || isLeader);

                int peerCount = peerReviewCount(peerReviews, t.getTaskId(), t.getAssigneeUserId());
                double peerAvg = peerReviewAverage(peerReviews, t.getTaskId(), t.getAssigneeUserId());
                PeerReviewView myReview = myPeerReview(peerReviews, t.getTaskId(), t.getAssigneeUserId(), currentUserId);
                LeaderReviewView leaderReview = leaderReviewOf(leaderReviews, t.getTaskId(), t.getAssigneeUserId());
            %>

                <article class="task-card-backend task-filter-card"
                         data-assignee-id="<%= t.getAssigneeUserId() %>">

                    <div class="task-card-head">
                        <div>
                            <h3><%= h(t.getTitle()) %></h3>
                            <p class="small-muted"><%= h(t.getDescription()) %></p>

                            <div class="task-meta">
                                <span>Task ID: <%= t.getTaskId() %></span>
                                <span>Assignment ID: <%= t.getAssignmentId() %></span>
                                <span>Người làm: <%= h(t.getAssigneeFullName()) %> (@<%= h(t.getAssigneeUsername()) %>)</span>
                                <span>Deadline: <%= fmt(t.getDeadline()) %></span>
                            </div>

                            <div class="task-compact-summary">
                                <span>
                                    Bài nộp
                                    <b><%= t.getSubmissionId() == null ? "Chưa nộp" : "Đã nộp" %></b>
                                </span>

                                <span>
                                    AI Review
                                    <b><%= t.getAiEvaluationId() == null ? "Chưa chấm" : stars(t.getAiStar()) %></b>
                                </span>

                                <span>
                                    Peer Review
                                    <b><%= peerCount == 0 ? "Chưa có" : peerAvg + "/5 (" + peerCount + ")" %></b>
                                </span>
                                
                                <span>
    								Leader Review
    								<b><%= leaderReview == null ? "Chưa chấm" : stars(leaderReview.getStar()) %></b>
								</span>

                                <span>
                                    Tiến độ
                                    <b><%= t.getProgress() %>%</b>
                                </span>
                            </div>
                        </div>
                    </div>

                    <details class="review-details">
                        <summary>Bài nộp</summary>

                        <div class="review-details-body">
                            <% if (t.getSubmissionId() == null) { %>
                                <p class="small-muted">
                                    Chưa có file bài nộp.
                                </p>
                            <% } else { %>
                                <p class="small-muted">
                                    Submission ID: <b><%= t.getSubmissionId() %></b><br>
                                    File: <b><%= h(t.getFileName()) %></b><br>
                                    Lần nộp: <b><%= t.getSubmitVersion() %></b><br>
                                    Thời gian nộp: <b><%= fmt(t.getSubmittedAt()) %></b>
                                </p>
                            <% } %>

                            <% if (canUpload) { %>
                                <form class="upload-form"
                                      action="SubmitTaskServlet"
                                      method="post"
                                      enctype="multipart/form-data">

                                    <input type="hidden" name="assignmentId" value="<%= t.getAssignmentId() %>">

                                    <input type="file"
                                           name="submissionFile"
                                           required
                                           accept=".txt,.java,.jsp,.html,.css,.js,.sql,.xml,.json,.md,.properties">

                                    <button class="secondary-btn" type="submit">
                                        <%= t.getSubmissionId() == null ? "Upload bài làm" : "Upload lại bài làm" %>
                                    </button>
                                </form>
                            <% } else { %>
                                <p class="small-muted" style="margin-top:12px;">
                                    Chỉ thành viên được giao task này mới được upload bài.
                                </p>
                            <% } %>
                        </div>
                    </details>

                    <details class="review-details">
                        <summary>Peer Review</summary>

                        <div class="review-details-body">
                            <% if (t.getSubmissionId() == null) { %>
                                <p class="small-muted">
                                    Task này chưa có bài nộp nên chưa thể peer review.
                                </p>
                            <% } else { %>

                                <% if (peerCount == 0) { %>
                                    <p class="small-muted">
                                        Chưa có peer review nào cho task này.
                                    </p>
                                <% } else { %>
                                    <p class="small-muted">
                                        Điểm peer trung bình:
                                        <b><%= peerAvg %>/5</b>
                                        từ
                                        <b><%= peerCount %></b>
                                        lượt đánh giá.
                                    </p>

                                    <p class="ai-star">
                                        <%= stars((int) Math.round(peerAvg)) %>
                                    </p>
                                <% } %>

                                <% if (currentUserId == t.getAssigneeUserId()) { %>
                                    <p class="small-muted" style="margin-top:12px;">
                                        Bạn không thể tự peer review task của chính mình.
                                    </p>
                                <% } else { %>
                                    <form action="PeerReviewServlet"
                                          method="post"
                                          class="task-create-form"
                                          style="margin-top:14px;">

                                        <input type="hidden" name="groupId" value="<%= groupId %>">
                                        <input type="hidden" name="taskId" value="<%= t.getTaskId() %>">
                                        <input type="hidden" name="reviewedUserId" value="<%= t.getAssigneeUserId() %>">

                                        <div class="task-create-grid" style="grid-template-columns:220px 1fr;">
                                            <div class="form-group">
                                                <label>Chấm sao</label>

                                                <select name="star" required>
                                                    <option value="">Chọn sao</option>

                                                    <option value="5" <%= myReview != null && myReview.getStar() == 5 ? "selected" : "" %>>
                                                        5 sao - Xuất sắc
                                                    </option>

                                                    <option value="4" <%= myReview != null && myReview.getStar() == 4 ? "selected" : "" %>>
                                                        4 sao - Tốt
                                                    </option>

                                                    <option value="3" <%= myReview != null && myReview.getStar() == 3 ? "selected" : "" %>>
                                                        3 sao - Đạt
                                                    </option>

                                                    <option value="2" <%= myReview != null && myReview.getStar() == 2 ? "selected" : "" %>>
                                                        2 sao - Cần sửa
                                                    </option>

                                                    <option value="1" <%= myReview != null && myReview.getStar() == 1 ? "selected" : "" %>>
                                                        1 sao - Kém
                                                    </option>
                                                </select>
                                            </div>

                                            <div class="form-group">
                                                <label>Nhận xét peer review</label>

                                                <textarea name="comment"
                                                          rows="3"
                                                          placeholder="Nhập nhận xét về bài làm, tiến độ hoặc mức đóng góp..."><%= myReview != null ? h(myReview.getComment()) : "" %></textarea>
                                            </div>
                                        </div>

                                        <div class="modal-actions">
                                            <button class="secondary-btn" type="submit">
                                                <%= myReview == null ? "Gửi peer review" : "Cập nhật peer review" %>
                                            </button>
                                        </div>
                                    </form>
                                <% } %>

                                <% if (peerCount > 0) { %>
                                    <div style="margin-top:16px;">
                                        <h4>Danh sách đánh giá</h4>

                                        <div class="task-card-list">
                                            <% for (PeerReviewView review : peerReviews) {
                                                if (review.getTaskId() != null
                                                        && review.getTaskId().intValue() == t.getTaskId()
                                                        && review.getReviewedUserId() == t.getAssigneeUserId()) {
                                            %>

                                                <div class="task-card-backend" style="padding:14px;">
                                                    <p class="small-muted">
                                                        <b><%= h(review.getReviewerFullName()) %></b>
                                                        (@<%= h(review.getReviewerUsername()) %>)
                                                        đã chấm:
                                                        <b><%= review.getStar() %>/5</b>
                                                        <span class="ai-star"><%= stars(review.getStar()) %></span>
                                                    </p>

                                                    <p class="small-muted">
                                                        <%= h(review.getComment()) %>
                                                    </p>

                                                    <p class="small-muted">
                                                        Thời gian: <%= fmt(review.getReviewTime()) %>
                                                    </p>
                                                </div>

                                            <% } } %>
                                        </div>
                                    </div>
                                <% } %>

                            <% } %>
                        </div>
                    </details>

					<details class="review-details">
    <summary>Leader Review</summary>

    <div class="review-details-body">
        <% if (t.getSubmissionId() == null) { %>
            <p class="small-muted">
                Task này chưa có bài nộp nên nhóm trưởng chưa thể đánh giá.
            </p>
        <% } else { %>

            <% if (leaderReview == null) { %>
                <p class="small-muted">
                    Chưa có đánh giá của nhóm trưởng cho task này.
                </p>
            <% } else { %>
                <div class="ai-result-card">
                    <h4>Đánh giá của nhóm trưởng</h4>

                    <p class="ai-star">
                        <%= stars(leaderReview.getStar()) %>
                    </p>

                    <p>
                        <b>Người chấm:</b>
                        <%= h(leaderReview.getLeaderFullName()) %>
                        (@<%= h(leaderReview.getLeaderUsername()) %>)
                    </p>

                    <p>
                        <b>Nhận xét:</b>
                        <%= h(leaderReview.getComment()) %>
                    </p>

                    <p class="small-muted">
                        Chấm lúc: <%= fmt(leaderReview.getReviewTime()) %>
                    </p>
                </div>
            <% } %>

            <% if (isLeader) { %>

                <% if (currentUserId == t.getAssigneeUserId()) { %>
                    <p class="small-muted" style="margin-top:12px;">
                        Nhóm trưởng không thể tự chấm task của chính mình.
                    </p>
                <% } else { %>

                    <form action="LeaderReviewServlet"
                          method="post"
                          class="task-create-form"
                          style="margin-top:14px;">

                        <input type="hidden" name="groupId" value="<%= groupId %>">
                        <input type="hidden" name="taskId" value="<%= t.getTaskId() %>">
                        <input type="hidden" name="reviewedUserId" value="<%= t.getAssigneeUserId() %>">

                        <div class="task-create-grid" style="grid-template-columns:220px 1fr;">
                            <div class="form-group">
                                <label>Nhóm trưởng chấm sao</label>

                                <select name="star" required>
                                    <option value="">Chọn sao</option>

                                    <option value="5" <%= leaderReview != null && leaderReview.getStar() == 5 ? "selected" : "" %>>
                                        5 sao - Xuất sắc
                                    </option>

                                    <option value="4" <%= leaderReview != null && leaderReview.getStar() == 4 ? "selected" : "" %>>
                                        4 sao - Tốt
                                    </option>

                                    <option value="3" <%= leaderReview != null && leaderReview.getStar() == 3 ? "selected" : "" %>>
                                        3 sao - Đạt
                                    </option>

                                    <option value="2" <%= leaderReview != null && leaderReview.getStar() == 2 ? "selected" : "" %>>
                                        2 sao - Cần sửa
                                    </option>

                                    <option value="1" <%= leaderReview != null && leaderReview.getStar() == 1 ? "selected" : "" %>>
                                        1 sao - Kém
                                    </option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Nhận xét của nhóm trưởng</label>

                                <textarea name="comment"
                                          rows="3"
                                          placeholder="Nhận xét chất lượng bài làm, mức độ hoàn thành và đóng góp..."><%= leaderReview != null ? h(leaderReview.getComment()) : "" %></textarea>
                            </div>
                        </div>

                        <div class="modal-actions">
                            <button class="primary-btn" type="submit">
                                <%= leaderReview == null ? "Gửi Leader Review" : "Cập nhật Leader Review" %>
                            </button>
                        </div>
                    </form>

                <% } %>

            <% } else { %>
                <p class="small-muted" style="margin-top:12px;">
                    Chỉ nhóm trưởng mới có quyền gửi Leader Review.
                </p>
            <% } %>

        <% } %>
    </div>
</details>
						
                    <details class="review-details">
                        <summary>AI Review</summary>

                        <div class="review-details-body">
                            <% if (t.getSubmissionId() == null) { %>
                                <p class="small-muted">
                                    Chưa có bài nộp nên chưa thể AI đánh giá.
                                </p>
                            <% } else { %>

                                <% if (canEvaluate) { %>
                                    <button class="primary-btn ai-evaluate-btn"
                                            type="button"
                                            data-submission-id="<%= t.getSubmissionId() %>">
                                        <%= t.getAiEvaluationId() == null ? "AI đánh giá" : "AI đánh giá lại" %>
                                    </button>
                                <% } else { %>
                                    <p class="small-muted">
                                        Chỉ chủ bài nộp hoặc nhóm trưởng có thể bấm AI đánh giá.
                                    </p>
                                <% } %>

                                <div id="aiResult-<%= t.getSubmissionId() %>">
                                    <% if (t.getAiEvaluationId() != null) { %>
                                        <div class="ai-result-card">
                                            <h4>Kết quả AI gần nhất</h4>

                                            <p class="ai-star">
                                                <%= stars(t.getAiStar()) %>
                                            </p>

                                            <p>
                                                <b>Điểm quy đổi:</b>
                                                <%= t.getConvertedPoint() %>
                                            </p>

                                            <p>
                                                <b>Nhận xét:</b>
                                                <%= h(t.getAiSummary()) %>
                                            </p>

                                            <p>
                                                <b>Điểm mạnh:</b>
                                                <%= h(t.getAiStrengths()) %>
                                            </p>

                                            <p>
                                                <b>Điểm yếu / thiếu sót:</b>
                                                <%= h(t.getAiWeaknesses()) %>
                                            </p>

                                            <p class="small-muted">
                                                Chấm lúc: <%= fmt(t.getEvaluatedAt()) %>
                                            </p>
                                        </div>
                                    <% } else { %>
                                        <p class="small-muted" style="margin-top:12px;">
                                            Chưa có kết quả AI.
                                        </p>
                                    <% } %>
                                </div>

                            <% } %>
                        </div>
                    </details>
                </article>
            <% } %>
        </div>
    <% } %>
</section>
    </main>
</div>

<script src="assets/js/ai-evaluation.js"></script>

<script>
var stockMembers = [
    <% for (int i = 0; i < members.size(); i++) {
        MemberStock m = members.get(i);
    %>
    {
        userId: <%= m.getUserId() %>,
        name: '<%= js(m.getFullName()) %>',
        username: '<%= js(m.getUsername()) %>',
        stockCode: '<%= js(m.getStockCode()) %>',
        currentPrice: <%= m.getCurrentPrice() %>
    }<%= i < members.size() - 1 ? "," : "" %>
    <% } %>
];

var stockHistories = [
    <% for (int i = 0; i < stockHistories.size(); i++) {
        StockHistoryView h = stockHistories.get(i);
    %>
    {
        historyId: <%= h.getHistoryId() %>,
        userId: <%= h.getUserId() %>,
        name: '<%= js(h.getFullName()) %>',
        username: '<%= js(h.getUsername()) %>',
        stockCode: '<%= js(h.getStockCode()) %>',
        taskId: <%= h.getTaskId() == null ? "null" : h.getTaskId() %>,
        sourceType: '<%= js(h.getSourceType()) %>',
        priceBefore: <%= h.getPriceBefore() %>,
        priceAfter: <%= h.getPriceAfter() %>,
        priceChange: <%= h.getPriceChange() %>,
        reason: '<%= js(h.getChangeReason()) %>',
        recordedAt: '<%= js(fmt(h.getRecordedAt())) %>'
    }<%= i < stockHistories.size() - 1 ? "," : "" %>
    <% } %>
];

var lineColors = [
    '#38bdf8', '#facc15', '#4ade80', '#a78bfa',
    '#fb7185', '#22d3ee', '#f97316', '#60a5fa'
];

(function () {
    function startStockChart() {
        var info = document.getElementById('stockChartInfo');

        try {
            var select = document.getElementById('stockChartMemberSelect');
            var refreshBtn = document.getElementById('refreshStockChartBtn');
            var canvas = document.getElementById('stockChartCanvas');

            if (!canvas) {
                if (info) info.innerHTML = 'Không tìm thấy canvas biểu đồ.';
                return;
            }

            if (!select) {
                if (info) info.innerHTML = 'Không tìm thấy bộ lọc biểu đồ.';
                return;
            }

            drawStockChart();

            select.onchange = function () {
                drawStockChart();
            };

            if (refreshBtn) {
                refreshBtn.onclick = function () {
                    drawStockChart();
                };
            }

        } catch (error) {
            console.log(error);
            if (info) {
                info.innerHTML = 'Lỗi JS biểu đồ: ' + escapeHtml(error.message);
            }
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', startStockChart);
    } else {
        startStockChart();
    }
})();

function drawStockChart() {
    var select = document.getElementById('stockChartMemberSelect');
    var selectedValue = select ? select.value : 'all';

    if (selectedValue === 'all') {
        drawAllMembersLineChart();
    } else {
        drawMemberHistoryLineChart(Number(selectedValue));
    }
}

function setupCanvas() {
    var canvas = document.getElementById('stockChartCanvas');

    if (!canvas) return null;

    var ctx = canvas.getContext('2d');
    var rect = canvas.getBoundingClientRect();
    var ratio = window.devicePixelRatio || 1;

    var width = rect.width || 900;
    var height = 340;

    canvas.width = width * ratio;
    canvas.height = height * ratio;

    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);

    return {
        canvas: canvas,
        ctx: ctx,
        width: width,
        height: height
    };
}

function getMemberById(userId) {
    for (var i = 0; i < stockMembers.length; i++) {
        if (Number(stockMembers[i].userId) === Number(userId)) {
            return stockMembers[i];
        }
    }
    return null;
}

function getHistoriesByUserId(userId) {
    var list = [];
    for (var i = 0; i < stockHistories.length; i++) {
        if (Number(stockHistories[i].userId) === Number(userId)) {
            list.push(stockHistories[i]);
        }
    }
    return list;
}

function buildSeriesForUser(userId) {
    var member = getMemberById(userId);
    var histories = getHistoriesByUserId(userId);

    if (!member) return null;

    var points = [];

    if (histories.length === 0) {
        points.push({
            label: 'Hiện tại',
            price: Number(member.currentPrice || 100)
        });
    } else {
        points.push({
            label: 'Ban đầu',
            price: Number(histories[0].priceBefore || 100)
        });

        for (var i = 0; i < histories.length; i++) {
            points.push({
                label: 'Mốc ' + (i + 1),
                price: Number(histories[i].priceAfter || 0),
                rawTime: histories[i].recordedAt,
                priceChange: Number(histories[i].priceChange || 0)
            });
        }
    }

    return {
        userId: member.userId,
        name: member.name,
        username: member.username,
        stockCode: member.stockCode,
        currentPrice: member.currentPrice,
        points: points
    };
}

function drawAllMembersLineChart() {
    var chart = setupCanvas();
    if (!chart) return;

    var ctx = chart.ctx;
    var width = chart.width;
    var height = chart.height;

    ctx.clearRect(0, 0, width, height);

    var info = document.getElementById('stockChartInfo');
    var list = document.getElementById('stockHistoryList');
    var legend = document.getElementById('stockChartLegend');

    if (!stockMembers || stockMembers.length === 0) {
        drawEmptyChart(ctx, width, height, 'Chưa có thành viên để hiển thị.');
        if (info) info.innerHTML = 'Chưa có dữ liệu thành viên.';
        if (list) list.innerHTML = '';
        if (legend) legend.innerHTML = '';
        return;
    }

    var seriesList = [];
    var maxPoints = 0;
    var minPrice = null;
    var maxPrice = null;

    for (var i = 0; i < stockMembers.length; i++) {
        var series = buildSeriesForUser(stockMembers[i].userId);
        if (series) {
            seriesList.push(series);

            if (series.points.length > maxPoints) {
                maxPoints = series.points.length;
            }

            for (var j = 0; j < series.points.length; j++) {
                var price = Number(series.points[j].price || 0);

                if (minPrice === null || price < minPrice) minPrice = price;
                if (maxPrice === null || price > maxPrice) maxPrice = price;
            }
        }
    }

    if (!seriesList.length) {
        drawEmptyChart(ctx, width, height, 'Không có dữ liệu biểu đồ.');
        if (info) info.innerHTML = 'Không có dữ liệu biểu đồ.';
        if (legend) legend.innerHTML = '';
        return;
    }

    if (minPrice === maxPrice) {
        minPrice = minPrice - 10;
        maxPrice = maxPrice + 10;
    }

    var padding = 46;
    var chartWidth = width - padding * 2;
    var chartHeight = height - padding * 2;
    var range = maxPrice - minPrice;

    drawAxes(ctx, padding, width, height, minPrice, maxPrice);

    if (maxPoints < 2) maxPoints = 2;

    for (var s = 0; s < seriesList.length; s++) {
        var lineColor = lineColors[s % lineColors.length];
        var points = seriesList[s].points;

        ctx.strokeStyle = lineColor;
        ctx.lineWidth = 2.2;
        ctx.beginPath();

        for (var p = 0; p < points.length; p++) {
            var x = padding + p * (chartWidth / (maxPoints - 1));
            var y = height - padding - ((points[p].price - minPrice) / range) * chartHeight;

            points[p].x = x;
            points[p].y = y;

            if (p === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }

        ctx.stroke();

        for (var q = 0; q < points.length; q++) {
            var dotColor = lineColor;

            if (q > 0) {
                if (points[q].price > points[q - 1].price) {
                    dotColor = '#22c55e'; // xanh
                } else if (points[q].price < points[q - 1].price) {
                    dotColor = '#ef4444'; // đỏ
                } else {
                    dotColor = '#facc15'; // vàng
                }
            }

            ctx.fillStyle = dotColor;
            ctx.beginPath();
            ctx.arc(points[q].x, points[q].y, 4.5, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    drawXAxisLabels(ctx, padding, width, height, maxPoints);
    drawLegend(seriesList);

    if (info) {
        info.innerHTML = 'Đang xem <b>biến động coin của toàn bộ thành viên</b>. Chấm <b style="color:#22c55e">xanh</b> là tăng, <b style="color:#ef4444">đỏ</b> là giảm, <b style="color:#facc15">vàng</b> là giữ nguyên.';
    }

    if (list) {
        var html = '';
        if (!stockHistories.length) {
            html = '<div class="stock-history-item">Chưa có lịch sử biến động coin.</div>';
        } else {
            var shown = 0;
            for (var k = stockHistories.length - 1; k >= 0 && shown < 8; k--) {
                html += renderHistoryItem(stockHistories[k]);
                shown++;
            }
        }
        list.innerHTML = html;
    }
}

function drawMemberHistoryLineChart(userId) {
    var chart = setupCanvas();
    if (!chart) return;

    var ctx = chart.ctx;
    var width = chart.width;
    var height = chart.height;

    ctx.clearRect(0, 0, width, height);

    var info = document.getElementById('stockChartInfo');
    var list = document.getElementById('stockHistoryList');
    var legend = document.getElementById('stockChartLegend');

    var series = buildSeriesForUser(userId);

    if (!series) {
        drawEmptyChart(ctx, width, height, 'Không tìm thấy thành viên.');
        if (info) info.innerHTML = 'Không tìm thấy thành viên.';
        if (list) list.innerHTML = '';
        if (legend) legend.innerHTML = '';
        return;
    }

    var points = series.points;

    if (!points.length) {
        drawEmptyChart(ctx, width, height, 'Chưa có dữ liệu.');
        if (info) info.innerHTML = 'Chưa có dữ liệu biểu đồ.';
        if (list) list.innerHTML = '';
        if (legend) legend.innerHTML = '';
        return;
    }

    var minPrice = points[0].price;
    var maxPrice = points[0].price;

    for (var i = 0; i < points.length; i++) {
        if (points[i].price < minPrice) minPrice = points[i].price;
        if (points[i].price > maxPrice) maxPrice = points[i].price;
    }

    if (minPrice === maxPrice) {
        minPrice -= 10;
        maxPrice += 10;
    }

    var padding = 46;
    var chartWidth = width - padding * 2;
    var chartHeight = height - padding * 2;
    var range = maxPrice - minPrice;

    drawAxes(ctx, padding, width, height, minPrice, maxPrice);

    var lineColor = '#38bdf8';

    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 3;
    ctx.beginPath();

    for (var p = 0; p < points.length; p++) {
        var x = padding + (points.length === 1 ? 0 : p * (chartWidth / (points.length - 1)));
        var y = height - padding - ((points[p].price - minPrice) / range) * chartHeight;

        points[p].x = x;
        points[p].y = y;

        if (p === 0) {
            ctx.moveTo(x, y);
        } else {
            ctx.lineTo(x, y);
        }
    }

    ctx.stroke();

    for (var q = 0; q < points.length; q++) {
        var dotColor = lineColor;

        if (q > 0) {
            if (points[q].price > points[q - 1].price) {
                dotColor = '#22c55e';
            } else if (points[q].price < points[q - 1].price) {
                dotColor = '#ef4444';
            } else {
                dotColor = '#facc15';
            }
        }

        ctx.fillStyle = dotColor;
        ctx.beginPath();
        ctx.arc(points[q].x, points[q].y, 5, 0, Math.PI * 2);
        ctx.fill();

        ctx.fillStyle = '#e2e8f0';
        ctx.font = 'bold 12px Arial';
        ctx.textAlign = 'center';
        ctx.fillText(Math.round(points[q].price), points[q].x, points[q].y - 10);
    }

    drawXAxisLabels(ctx, padding, width, height, points.length);

    if (legend) {
        legend.innerHTML =
            '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#38bdf8"></span>' + escapeHtml(series.name) + '</div>' +
            '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#22c55e"></span>Tăng</div>' +
            '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#ef4444"></span>Giảm</div>' +
            '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#facc15"></span>Không đổi</div>';
    }

    if (info) {
        info.innerHTML = 'Đang xem biểu đồ của <b>' + escapeHtml(series.name) + '</b> (@' + escapeHtml(series.username) + ').';
    }

    if (list) {
        var histories = getHistoriesByUserId(userId);
        var html = '';

        if (!histories.length) {
            html = '<div class="stock-history-item">Chưa có lịch sử biến động.</div>';
        } else {
            var shown = 0;
            for (var h = histories.length - 1; h >= 0 && shown < 8; h--) {
                html += renderHistoryItem(histories[h]);
                shown++;
            }
        }

        list.innerHTML = html;
    }
}

function drawLegend(seriesList) {
    var legend = document.getElementById('stockChartLegend');
    if (!legend) return;

    var html = '';

    for (var i = 0; i < seriesList.length; i++) {
        var color = lineColors[i % lineColors.length];
        html += ''
            + '<div class="stock-chart-legend-item">'
            + '<span class="stock-chart-legend-color" style="background:' + color + '"></span>'
            + escapeHtml(seriesList[i].name)
            + '</div>';
    }

    html += '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#22c55e"></span>Tăng</div>';
    html += '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#ef4444"></span>Giảm</div>';
    html += '<div class="stock-chart-legend-item"><span class="stock-chart-legend-color" style="background:#facc15"></span>Không đổi</div>';

    legend.innerHTML = html;
}

function drawAxes(ctx, padding, width, height, minPrice, maxPrice) {
    ctx.strokeStyle = 'rgba(148,163,184,.35)';
    ctx.lineWidth = 1;

    ctx.beginPath();
    ctx.moveTo(padding, padding);
    ctx.lineTo(padding, height - padding);
    ctx.lineTo(width - padding, height - padding);
    ctx.stroke();

    var steps = 4;
    ctx.fillStyle = '#94a3b8';
    ctx.font = '11px Arial';
    ctx.textAlign = 'right';

    for (var i = 0; i <= steps; i++) {
        var value = minPrice + ((maxPrice - minPrice) / steps) * i;
        var y = height - padding - ((value - minPrice) / (maxPrice - minPrice)) * (height - padding * 2);

        ctx.strokeStyle = 'rgba(148,163,184,.12)';
        ctx.beginPath();
        ctx.moveTo(padding, y);
        ctx.lineTo(width - padding, y);
        ctx.stroke();

        ctx.fillStyle = '#94a3b8';
        ctx.fillText(Math.round(value), padding - 8, y + 4);
    }

    ctx.save();
    ctx.translate(16, height / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.fillStyle = '#94a3b8';
    ctx.font = '12px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('Số coin', 0, 0);
    ctx.restore();
}

function drawXAxisLabels(ctx, padding, width, height, count) {
    if (count < 1) return;

    var chartWidth = width - padding * 2;

    ctx.fillStyle = '#94a3b8';
    ctx.font = '11px Arial';
    ctx.textAlign = 'center';

    for (var i = 0; i < count; i++) {
        var x = padding + (count === 1 ? 0 : i * (chartWidth / (count - 1)));
        ctx.fillText('Mốc ' + (i + 1), x, height - 18);
    }

    ctx.fillText('Thời gian', width / 2, height - 2);
}

function drawEmptyChart(ctx, width, height, message) {
    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = '#94a3b8';
    ctx.font = 'bold 16px Arial';
    ctx.textAlign = 'center';
    ctx.fillText(message, width / 2, height / 2);
}

function renderHistoryItem(item) {
    var change = Number(item.priceChange || 0);
    var sign = change >= 0 ? '+' : '';

    return ''
        + '<div class="stock-history-item">'
        + '<b>' + escapeHtml(item.name) + '</b> '
        + '(@' + escapeHtml(item.username) + ')'
        + ' · ' + escapeHtml(item.sourceType)
        + ' · Task #' + escapeHtml(item.taskId || '--')
        + ' · <b>' + sign + change.toFixed(2) + '</b> coin'
        + '<br>'
        + Number(item.priceBefore || 0).toFixed(2)
        + ' → '
        + Number(item.priceAfter || 0).toFixed(2)
        + ' · ' + escapeHtml(item.recordedAt)
        + '<br>'
        + '<span>' + escapeHtml(item.reason) + '</span>'
        + '</div>';
}

function escapeHtml(value) {
    if (value === null || value === undefined) return '';
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}
</script>

<!-- SCRIPT XẾP HẠNG COIN TẠI MỘT THỜI ĐIỂM -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    var rankingForm = document.getElementById("coinRankingForm");

    if (!rankingForm) {
        return;
    }

    rankingForm.addEventListener("submit", function (event) {
        event.preventDefault();
        loadCoinRanking();
    });
});

function loadCoinRanking() {
    var form = document.getElementById("coinRankingForm");
    var resultBox = document.getElementById("coinRankingResult");

    if (!form || !resultBox) {
        return;
    }

    var formData = new FormData(form);
    var params = new URLSearchParams(formData);

    resultBox.innerHTML = '<p class="small-muted">Đang tải bảng xếp hạng coin...</p>';

    fetch("CoinRankingServlet?" + params.toString())
        .then(function (response) {
            return response.json();
        })
        .then(function (data) {
            if (!data.success) {
                resultBox.innerHTML =
                    '<div class="backend-message" style="background:rgba(239,68,68,.12);border-color:rgba(239,68,68,.28);color:#fecaca;">'
                    + escapeHtml(data.message || "Không thể tải bảng xếp hạng.")
                    + '</div>';
                return;
            }

            renderCoinRanking(data.ranking || [], data.queryTime);
        })
        .catch(function (error) {
            resultBox.innerHTML =
                '<div class="backend-message" style="background:rgba(239,68,68,.12);border-color:rgba(239,68,68,.28);color:#fecaca;">'
                + 'Lỗi tải bảng xếp hạng: ' + escapeHtml(error.message)
                + '</div>';
        });
}

function renderCoinRanking(ranking, queryTime) {
    var resultBox = document.getElementById("coinRankingResult");

    if (!resultBox) {
        return;
    }

    if (!ranking.length) {
        resultBox.innerHTML = '<p class="small-muted">Không có dữ liệu xếp hạng coin tại thời điểm này.</p>';
        return;
    }

    var title = '';

    if (queryTime && queryTime.trim() !== '') {
        title = '<p class="small-muted">Đang xem xếp hạng coin tại thời điểm: <b>'
            + escapeHtml(queryTime.replace("T", " "))
            + '</b></p>';
    } else {
        title = '<p class="small-muted">Đang xem xếp hạng coin hiện tại.</p>';
    }

    var html = '';

    html += title;
    html += '<table class="coin-ranking-table">';
    html += '<thead>';
    html += '<tr>';
    html += '<th>Hạng</th>';
    html += '<th>Thành viên</th>';
    html += '<th>Mã coin</th>';
    html += '<th>Coin tại thời điểm</th>';
    html += '<th>Chênh lệch so với hiện tại</th>';
    html += '<th>Số lần biến động trước thời điểm</th>';
    html += '</tr>';
    html += '</thead>';
    html += '<tbody>';

    for (var i = 0; i < ranking.length; i++) {
        var item = ranking[i];

        var diff = Number(item.periodChange || 0);
        var diffText = diff.toFixed(2);
        var diffClass = 'coin-equal';

        if (diff > 0) {
            diffText = '+' + diffText;
            diffClass = 'coin-up';
        } else if (diff < 0) {
            diffClass = 'coin-down';
        }

        var rankIcon = item.rank;

        if (item.rank === 1) {
            rankIcon = '🥇';
        } else if (item.rank === 2) {
            rankIcon = '🥈';
        } else if (item.rank === 3) {
            rankIcon = '🥉';
        }

        html += '<tr>';
        html += '<td><span class="rank-badge">' + rankIcon + '</span></td>';

        html += '<td>';
        html += '<b>' + escapeHtml(item.fullName) + '</b><br>';
        html += '<span class="small-muted">@' + escapeHtml(item.username) + ' · User ID: ' + item.userId + '</span>';
        html += '</td>';

        html += '<td><b>' + escapeHtml(item.stockCode) + '</b></td>';

        html += '<td><b>' + Number(item.currentPrice || 0).toFixed(2) + '</b></td>';

        html += '<td class="' + diffClass + '">' + diffText + '</td>';

        html += '<td>' + item.changeCount + '</td>';
        html += '</tr>';
    }

    html += '</tbody>';
    html += '</table>';

    resultBox.innerHTML = html;
}
</script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const filterButtons = document.querySelectorAll(".member-filter-btn");
    const taskCards = document.querySelectorAll(".task-filter-card");
    const emptyState = document.getElementById("filterEmptyState");

    function applyFilter(memberId) {
        let visibleCount = 0;

        taskCards.forEach(function (card) {
            const assigneeId = card.getAttribute("data-assignee-id");

            if (memberId === "all" || assigneeId === memberId) {
                card.style.display = "";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });

        if (emptyState) {
            emptyState.style.display = visibleCount === 0 ? "block" : "none";
        }
    }

    filterButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            const memberId = button.getAttribute("data-member-filter");

            filterButtons.forEach(function (btn) {
                btn.classList.remove("active");
            });

            button.classList.add("active");
            applyFilter(memberId);
        });
    });
});
</script>


</body>
</html>