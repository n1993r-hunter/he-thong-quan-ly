<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký - Hệ Thống Quản Lý</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; margin-top: 80px; background-color: #f4f7f6; }
        .register-box { border: 1px solid #ddd; padding: 30px; border-radius: 10px; width: 350px; background: white; box-shadow: 0px 4px 10px rgba(0,0,0,0.1); text-align: center; }
        input { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; }
        button { width: 96%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #0056b3; }
        .msg-error { color: red; }
        .msg-success { color: green; }
    </style>
</head>
<body>
    <div class="register-box">
        <h2>Tạo Tài Khoản</h2>
        
        <%-- Hiển thị thông báo nếu đăng ký thất bại --%>
        <% if("fail".equals(request.getParameter("msg"))) { %>
            <p class="msg-error">Đăng ký thất bại! Vui lòng thử lại.</p>
        <% } %>

        <form action="RegisterServlet" method="POST">
            <input type="text" name="fullName" placeholder="Họ và tên" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="text" name="username" placeholder="Tên đăng nhập" required>
            <input type="password" name="password" placeholder="Mật khẩu" required>
            <button type="submit">Đăng Ký</button>
        </form>
        
        <div style="margin-top: 15px;">
            <a href="login.jsp" style="color: #666; text-decoration: none;">&larr; Quay lại Đăng nhập</a>
        </div>
    </div>
</body>
</html>