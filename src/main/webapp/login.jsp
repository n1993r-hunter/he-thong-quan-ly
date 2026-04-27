<%-- webapp/login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Zero-Sum Coin Exchange | Authentication</title>
    
    <jsp:include page="auth_ui.html" />
</head>
<body>

    <script>
        function getCookie(name) {
            let cookieArr = document.cookie.split(";");
            for(let i = 0; i < cookieArr.length; i++) {
                let cookiePair = cookieArr[i].split("=");
                if(name == cookiePair[0].trim()) return decodeURIComponent(cookiePair[1]);
            }
            return null;
        }

        window.onload = function() {
            // 1. Tự điền Cookie (Giữ nguyên)
            let savedUser = getCookie("cUser");
            let savedPass = getCookie("cPass");
            if (savedUser && savedPass) {
                if(document.getElementById('loginEmail')) document.getElementById('loginEmail').value = savedUser;
                if(document.getElementById('loginPassword')) document.getElementById('loginPassword').value = savedPass;
                if(document.querySelector('input[name="remember"]')) document.querySelector('input[name="remember"]').checked = true;
            }

            // 2. LOGIC HIỂN THỊ THÔNG BÁO (ƯU TIÊN LỖI)
            const canShow = (typeof showMessage === "function" && typeof switchForm === "function");
            if (!canShow) return;

            <%-- ƯU TIÊN 1: Lỗi từ LoginServlet --%>
            <% if (request.getAttribute("error") != null) { %>
                // --- SỬA TẠI ĐÂY: Đảo switchForm lên trước ---
                switchForm('login'); 
                showMessage('<%= request.getAttribute("error") %>', 'error');
                
                <% if (request.getAttribute("oldUsername") != null) { %>
                    const emailInput = document.getElementById('loginEmail');
                    if (emailInput) {
                        emailInput.value = '<%= request.getAttribute("oldUsername") %>';
                        document.getElementById('loginPassword').focus(); 
                    }
                <% } %>
                return; 
            <% } %>

            <%-- ƯU TIÊN 2: Thông báo từ URL --%>
            <% 
                String msg = request.getParameter("msg");
                
                if ("success".equals(msg)) { 
            %>
                switchForm('login');
                showMessage('Đăng ký thành công. Vui lòng đăng nhập.', 'success');
                
            <%  } else if ("fail".equals(msg)) { %>
                switchForm('register');
                showMessage('Đăng ký thất bại! Tài khoản hoặc Email đã tồn tại.', 'error');
                
            <%  } else if ("reset_success".equals(msg)) { %>
                switchForm('login');
                showMessage('Mật khẩu đã được cập nhật. Hãy đăng nhập lại!', 'success');
                
            <%  } else if ("email_not_found".equals(msg)) { %>
                switchForm('forgot');
                showMessage('Email này không tồn tại trong hệ thống!', 'error');
            <%  } %>
            
        };
    </script>
</body>
</html>