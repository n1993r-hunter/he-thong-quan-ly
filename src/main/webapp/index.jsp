<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %> 

<!DOCTYPE html>
<html>
<head>
    <title>Hệ Thống Quản Lý | Bảng Điều Khiển</title>
</head>
<body>
    <%-- Phần 1: Kiểm tra đăng nhập và chào mừng --%>
    <% 
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
    
    <%-- Phần 2: Form Tạo Nhóm --%>
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 400px; border-radius: 5px;">
        <h3>Tạo Dự Án / Nhóm Mới</h3>
        
        <%-- Xử lý thông báo trả về từ GroupServlet --%>
        <% if("group_created".equals(request.getParameter("msg"))) { %>
            <p style="color: green; font-weight: bold;">🎉 Đã tạo nhóm thành công và bạn là Leader!</p>
        <% } else if ("group_fail".equals(request.getParameter("msg"))) { %>
            <p style="color: red; font-weight: bold;">❌ Tạo nhóm thất bại! Vui lòng thử lại.</p>
        <% } %>
        
        <form action="GroupServlet" method="POST">
            <input type="text" name="groupName" placeholder="Tên dự án mới..." required style="width: 70%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">
            <button type="submit" style="padding: 6px 12px; background-color: #007bff; color: white; border: none; border-radius: 3px; cursor: pointer;">Tạo Nhóm</button>
        </form>
    </div>

    <%-- Phần 3 (MỚI KHÔI PHỤC): Form Thêm Thành Viên (Đã tinh gọn) --%>
    <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; width: 400px; border-radius: 5px;">
        <h3>Thêm Thành Viên Vào Nhóm</h3>
        
        <%-- Khu vực hiển thị thông báo kết quả thêm người --%>
        <% String msg = request.getParameter("msg"); %>
        <% if("add_success".equals(msg)) { %>
            <p style="color: green; font-weight: bold;">✅ Đã thêm thành viên thành công!</p>
        <% } else if("add_fail".equals(msg)) { %>
            <p style="color: red; font-weight: bold;">❌ Thất bại! Sai tên đăng nhập hoặc người này đã có trong nhóm.</p>
        <% } else if("invalid_group".equals(msg)) { %>
            <p style="color: red; font-weight: bold;">⚠️ Vui lòng nhập đúng ID Nhóm bằng số!</p>
        <% } %>
        
        <%-- Form gửi dữ liệu sang AddMemberServlet (Chỉ truyền ID và Username) --%>
        <form action="AddMemberServlet" method="POST">
            <div style="margin-bottom: 10px;">
                <label>ID Nhóm:</label><br>
                <input type="number" name="groupId" placeholder="Nhập số ID Nhóm..." required style="width: 95%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">
            </div>
            
            <div style="margin-bottom: 15px;">
                <label>Tên đăng nhập (Username):</label><br>
                <input type="text" name="username" placeholder="Nhập username đồng đội..." required style="width: 95%; padding: 6px; border-radius: 3px; border: 1px solid #ccc;">
            </div>
            
            <button type="submit" style="padding: 6px 12px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer;">
                Thêm Thành Viên
            </button>
        </form>
    </div>

</body>
</html>