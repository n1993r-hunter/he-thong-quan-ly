<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Zero-Sum Coin Exchange | Authentication</title>
    <%-- NHÚNG GIAO DIỆN CỦA TRÂM VÀO ĐÂY --%>
    <jsp:include page="auth_ui.html" />
</head>
<body>
    <script>
    document.addEventListener('DOMContentLoaded', function () {
        
        // 1. Xử lý lỗi Đăng nhập...
        <% if (request.getAttribute("error") != null) { %>
            if (typeof showMessage === "function") {
                showMessage('<%= request.getAttribute("error") %>', 'error');
                switchForm('login'); 
            }
        <% } %>

        // 2. Xử lý lỗi Đăng ký...
        <% if ("fail".equals(request.getParameter("msg"))) { %>
            if (typeof showMessage === "function") {
                showMessage('Đăng ký thất bại! Username hoặc Email đã tồn tại.', 'error');
                switchForm('register');
            }
        <% } %>

        // 3. XỬ LÝ ĐĂNG KÝ THÀNH CÔNG 
        <% if ("success".equals(request.getParameter("msg"))) { %>
            if (typeof switchForm === "function" && typeof showMessage === "function") {
                // Tự động gạt sang tab Đăng nhập
                switchForm('login');
                // Hiện thông báo màu xanh lá y hệt bản gốc
                showMessage('Đăng ký thành công. Vui lòng đăng nhập.', 'success');
            }
        <% } %>
        
    });
</script>
</body>
</html>