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
    <title>Hệ Thống Quản Lý</title>
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

    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px;">
        <h3>Tạo Dự Án / Nhóm Mới</h3>

        <% if ("group_created".equals(msg)) { %>
            <p style="color: green;">🎉 Đã tạo nhóm thành công và bạn là Leader!</p>
        <% } else if ("group_fail".equals(msg)) { %>
            <p style="color: red;">❌ Tạo nhóm thất bại, kiểm tra lại database hoặc code DAO!</p>
        <% } %>

        <form action="GroupServlet" method="POST">
            <input type="text"
                   name="groupName"
                   placeholder="Tên dự án mới..."
                   required
                   style="width: 70%; padding: 6px;">

            <button type="submit" style="padding: 6px 10px;">
                Tạo Nhóm
            </button>
        </form>
    </div>

    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px;">
        <h3>Quản lý nhóm</h3>

        <p>Xem các nhóm/dự án mà bạn đang tham gia.</p>

        <a href="MyGroupsServlet"
           style="display: inline-block; padding: 8px 15px; background-color: #007bff; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">
            Xem danh sách nhóm của tôi
        </a>
    </div>

</body>
</html>