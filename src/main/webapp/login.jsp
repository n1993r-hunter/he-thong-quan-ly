<%-- webapp/login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Zero-Sum Coin Exchange | Authentication</title>
    
    <%-- Nhúng giao diện tĩnh của Trâm --%>
    <jsp:include page="auth_ui.html" />
</head>
<body>

    <script>
        /**
         * Hàm bổ trợ đọc Cookie phục vụ tính năng "Ghi nhớ đăng nhập"
         */
        function getCookie(name) {
            let cookieArr = document.cookie.split(";");
            for(let i = 0; i < cookieArr.length; i++) {
                let cookiePair = cookieArr[i].split("=");
                if(name == cookiePair[0].trim()) return decodeURIComponent(cookiePair[1]);
            }
            return null;
        }

        /**
         * window.onload đảm bảo script chạy sau khi auth.js của Trâm đã tải xong
         */
        window.onload = function() {
            // --- 1. XỬ LÝ GHI NHỚ ĐĂNG NHẬP (COOKIE) ---
            let savedUser = getCookie("cUser");
            let savedPass = getCookie("cPass");
            if (savedUser && savedPass) {
                const loginEmailField = document.getElementById('loginEmail');
                const loginPasswordField = document.getElementById('loginPassword');
                const rememberCheckbox = document.querySelector('input[name="remember"]');

                if (loginEmailField) loginEmailField.value = savedUser;
                if (loginPasswordField) loginPasswordField.value = savedPass;
                if (rememberCheckbox) rememberCheckbox.checked = true;
            }

            // --- 2. LOGIC HIỂN THỊ THÔNG BÁO (ƯU TIÊN LỖI) ---
            const canShow = (typeof showMessage === "function" && typeof switchForm === "function");
            if (!canShow) return;

            <%-- ƯU TIÊN 1: Hiển thị lỗi từ LoginServlet (Dùng Attribute) --%>
            <% if (request.getAttribute("error") != null) { %>
                // Hiện thông báo lỗi màu đỏ
                showMessage('<%= request.getAttribute("error") %>', 'error');
                switchForm('login');
                
                // Điền lại Username đã nhập để không phải gõ lại
                <% if (request.getAttribute("oldUsername") != null) { %>
                    const emailInput = document.getElementById('loginEmail');
                    if (emailInput) {
                        emailInput.value = '<%= request.getAttribute("oldUsername") %>';
                        document.getElementById('loginPassword').focus(); 
                    }
                <% } %>
                
                // CỰC QUAN TRỌNG: Dừng xử lý tại đây nếu có lỗi đăng nhập
                // Để tránh việc tham số "msg=success" cũ trên URL làm hiện đè thông báo xanh
                return; 
            <% } %>

            <%-- ƯU TIÊN 2: Hiển thị thông báo từ RegisterServlet (Dùng Parameter) --%>
            <% 
                String msg = request.getParameter("msg"); 
                if ("success".equals(msg)) { 
            %>
                // CHÚ Ý: Gọi switchForm TRƯỚC để xóa message cũ, sau đó mới hiện showMessage
                switchForm('login');
                showMessage('Đăng ký thành công. Vui lòng đăng nhập.', 'success');
            <% } else if ("fail".equals(msg)) { %>
                switchForm('register');
                showMessage('Đăng ký thất bại! Tài khoản hoặc Email đã tồn tại.', 'error');
            <% } %>
        };
    </script>
</body>
</html>