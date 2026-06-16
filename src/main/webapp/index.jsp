<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
    User user = (User) session.getAttribute("loginedUser");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hệ Thống Quản Lý | Bảng Điều Khiển</title>
</head>
<body>

    <h1>Chào mừng <%= user.getFullName() %> đã trở lại! 🚀</h1>

    <p>Email của bạn là: <%= user.getEmail() %></p>
    <p>Vai trò của bạn trong hệ thống sẽ được hiển thị ở đây.</p>

    <div style="margin-top: 20px;">
        <a href="LogoutServlet"
           style="padding: 8px 15px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">
            Đăng xuất
        </a>
    </div>

    <hr>

    <!-- PHẦN 1: TẠO NHÓM -->
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px; border-radius: 5px;">
        <h3>Tạo Dự Án / Nhóm Mới</h3>

        <% if ("group_created".equals(msg)) { %>
            <p style="color: green; font-weight: bold;">🎉 Đã tạo nhóm thành công và bạn là Leader!</p>
        <% } else if ("group_fail".equals(msg)) { %>
            <p style="color: red; font-weight: bold;">❌ Tạo nhóm thất bại, kiểm tra lại database hoặc code DAO!</p>
        <% } %>

        <form action="GroupServlet" method="POST">
            <input type="text"
                   name="groupName"
                   placeholder="Tên dự án mới..."
                   required
                   style="width: 70%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">

            <button type="submit"
                    style="padding: 6px 12px; background-color: #007bff; color: white; border: none; border-radius: 3px; cursor: pointer;">
                Tạo Nhóm
            </button>
        </form>
    </div>

    <!-- PHẦN 2: XEM DANH SÁCH NHÓM -->
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px; border-radius: 5px;">
        <h3>Quản lý nhóm</h3>

        <p>Xem các nhóm/dự án mà bạn đang tham gia.</p>

        <a href="MyGroupsServlet"
           style="display: inline-block; padding: 8px 15px; background-color: #007bff; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">
            Xem danh sách nhóm của tôi
        </a>
    </div>

    <!-- PHẦN 3: THÊM THÀNH VIÊN VÀO NHÓM -->
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px; border-radius: 5px;">
        <h3>Thêm Thành Viên Vào Nhóm</h3>

        <% if ("add_success".equals(msg)) { %>
            <p style="color: green; font-weight: bold;">✅ Đã thêm thành viên thành công!</p>
        <% } else if ("add_fail".equals(msg)) { %>
            <p style="color: red; font-weight: bold;">❌ Thất bại! Sai tên đăng nhập hoặc người này đã có trong nhóm.</p>
        <% } else if ("invalid_group".equals(msg)) { %>
            <p style="color: red; font-weight: bold;">⚠️ Vui lòng nhập đúng ID Nhóm bằng số!</p>
        <% } %>

        <form action="AddMemberServlet" method="POST">
            <div style="margin-bottom: 10px;">
                <label>ID Nhóm:</label><br>
                <input type="number"
                       name="groupId"
                       placeholder="Nhập số ID Nhóm..."
                       required
                       style="width: 95%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">
            </div>

            <div style="margin-bottom: 15px;">
                <label>Tên đăng nhập (Username):</label><br>
                <input type="text"
                       name="username"
                       placeholder="Nhập username đồng đội..."
                       required
                       style="width: 95%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">
            </div>

            <button type="submit"
                    style="padding: 6px 12px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer;">
                Thêm Thành Viên
            </button>
        </form>
    </div>

</body>
</html>