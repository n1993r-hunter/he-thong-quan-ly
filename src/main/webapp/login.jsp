<%-- webapp/login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Zero-Sum Coin Exchange | Authentication</title>
    
    <%-- 1. NHÚNG GIAO DIỆN CỦA TRÂM: Giữ nguyên vẻ đẹp của Frontend --%>
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
            // 1. Tự điền Cookie
            let savedUser = getCookie("cUser");
            let savedPass = getCookie("cPass");
            if (savedUser && savedPass) {
                if(document.getElementById('loginEmail')) document.getElementById('loginEmail').value = savedUser;
                if(document.getElementById('loginPassword')) document.getElementById('loginPassword').value = savedPass;
                if(document.querySelector('input[name="remember"]')) document.querySelector('input[name="remember"]').checked = true;
            }

            // 2. HIỆN THÔNG BÁO LỖI TỪ SERVLET
            <% if (request.getAttribute("error") != null) { %>
                if (typeof showMessage === "function") {
                    // Hiện thông báo đỏ của Trâm
                    showMessage('<%= request.getAttribute("error") %>', 'error');
                }
                
                // Điền lại Username cũ
                <% if (request.getAttribute("oldUsername") != null) { %>
                    const emailInput = document.getElementById('loginEmail');
                    if (emailInput) {
                        emailInput.value = '<%= request.getAttribute("oldUsername") %>';
                        document.getElementById('loginPassword').focus(); 
                    }
                <% } %>
            <% } %>

            // 3. Xử lý các thông báo Msg khác
            <% if ("fail".equals(request.getParameter("msg"))) { %>
                if(typeof showMessage === "function") showMessage('Đăng ký thất bại!', 'error');
                if(typeof switchForm === "function") switchForm('register');
            <% } %>
        };
    </script>
</body>
</html>