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
        <a href="login.jsp">Đăng xuất</a>
    <% } else { %>
        <% response.sendRedirect("login.jsp"); %>
    <% } %>
</body>
</html>