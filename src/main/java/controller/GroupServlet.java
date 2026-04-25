package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import dao.GroupDAO;
import model.User;

@WebServlet("/GroupServlet")
public class GroupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // 1. Kiểm tra xem user đã đăng nhập chưa (Bảo mật)
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp"); // Đuổi ra ngoài nếu chưa đăng nhập
            return;
        }

        // 2. Lấy tên Nhóm/Dự án do user nhập
        String groupName = request.getParameter("groupName");

        // 3. Gọi DAO để lưu vào DB
        GroupDAO dao = new GroupDAO();
        boolean isSuccess = dao.createGroup(groupName, currentUser.getUserId());

        if (isSuccess) {
            // Trở về trang chủ kèm thông báo thành công
            response.sendRedirect("index.jsp?msg=group_created");
        } else {
            response.sendRedirect("index.jsp?msg=group_fail");
        }
    }
}