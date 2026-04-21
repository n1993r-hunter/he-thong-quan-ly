<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng nhập - Hệ Thống Quản Lý</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; margin-top: 100px; }
        .login-box { border: 1px solid #ccc; padding: 20px; border-radius: 8px; width: 300px; text-align: center; }
        input { width: 90%; padding: 8px; margin: 10px 0; }
        button { padding: 10px 20px; background-color: #28a745; color: white; border: none; cursor: pointer; }
        .error { color: red; font-size: 14px; }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>Đăng Nhập</h2>
        <p class="error">${error}</p> 
        
        <form action="LoginServlet" method="POST">
            <input type="text" name="username" placeholder="Tên đăng nhập" required>
            <input type="password" name="password" placeholder="Mật khẩu" required>
            <button type="submit">Đăng nhập</button>
        </form>
    </div>
    <div style="margin-top: 15px;">
    	<span>Chưa có tài khoản? </span>
    	<a href="register.jsp" style="color: #007bff; text-decoration: none;">Đăng ký ngay</a>
	</div>
</body>
</html>