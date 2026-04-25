<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %> 

<!DOCTYPE html>
<html>
<head>
    <title>Hệ Thống Quản Lý</title>
</head>
<body>
    <% 
        // Kiểm tra xem đã có ai đăng nhập chưa
        User user = (User) session.getAttribute("loginedUser");
        if(user != null) { 
    %>
        <h1>Chào mừng <%= user.getFullName() %> đã trở lại! 🚀</h1>
        <p>Email của bạn là: <%= user.getEmail() %></p>
        <p>Vai trò của bạn trong hệ thống sẽ được hiển thị ở đây.</p>
        <div style="margin-top: 20px;">
    		<a href="LogoutServlet" style="padding: 8px 15px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">
        Đăng xuất
    		</a>
		</div>
    <% } else { %>
        <% response.sendRedirect("login.jsp"); %>
    <% } %>
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 400px;">
    <h3>Tạo Dự Án / Nhóm Mới</h3>
    
    <% if("group_created".equals(request.getParameter("msg"))) { %>
        <p style="color: green;">🎉 Đã tạo nhóm thành công và bạn là Leader!</p>
    <% } %>
    
    <form action="GroupServlet" method="POST">
        <input type="text" name="groupName" placeholder="Tên dự án mới..." required style="width: 70%; padding: 5px;">
        <button type="submit" style="padding: 5px 10px;">Tạo Nhóm</button>
    </form>
</div>
</body>
</html>