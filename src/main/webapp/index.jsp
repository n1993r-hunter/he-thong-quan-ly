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

    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 420px; border-radius: 5px;">
    <h3>Gia nhập nhóm</h3>

    <p>Nhập ID nhóm để gửi yêu cầu gia nhập. Leader sẽ duyệt yêu cầu của bạn.</p>

    <% if ("join_sent".equals(msg)) { %>
        <p style="color: green; font-weight: bold;">✅ Đã gửi yêu cầu gia nhập nhóm. Vui lòng chờ leader duyệt.</p>
    <% } else if ("join_group_not_found".equals(msg)) { %>
        <p style="color: red; font-weight: bold;">❌ Không tìm thấy nhóm với ID này.</p>
    <% } else if ("join_already_member".equals(msg)) { %>
        <p style="color: red; font-weight: bold;">⚠️ Bạn đã là thành viên của nhóm này rồi.</p>
    <% } else if ("join_already_pending".equals(msg)) { %>
        <p style="color: red; font-weight: bold;">⏳ Bạn đã gửi yêu cầu trước đó. Vui lòng chờ leader duyệt.</p>
    <% } else if ("join_fail".equals(msg)) { %>
        <p style="color: red; font-weight: bold;">❌ Gửi yêu cầu thất bại. Vui lòng thử lại.</p>
    <% } else if ("invalid_group".equals(msg)) { %>
        <p style="color: red; font-weight: bold;">⚠️ ID nhóm không hợp lệ.</p>
    <% } %>

    <form action="JoinGroupRequestServlet" method="POST">
        <input type="number"
               name="groupId"
               placeholder="Nhập ID nhóm..."
               required
               style="width: 70%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">

        <button type="submit"
                style="padding: 6px 12px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer;">
            Gửi yêu cầu
        </button>
    </form>
</div>

</body>
</html>