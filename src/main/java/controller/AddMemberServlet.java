package controller;

import java.io.IOException;

import dao.GroupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/AddMemberServlet")
public class AddMemberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // 1. Bảo mật: Yêu cầu đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Nhận dữ liệu (Chỉ còn ID Nhóm và Username)
            int groupId = Integer.parseInt(request.getParameter("groupId"));
            String newUsername = request.getParameter("username");

            // 3. Gọi DAO xử lý
            GroupDAO dao = new GroupDAO();
            // Đã bỏ tham số role
            boolean isSuccess = dao.addMemberToGroup(groupId, newUsername);

            // 4. Trả kết quả về Frontend
            if (isSuccess) {
                response.sendRedirect("group_detail.jsp?id=" + groupId + "&msg=add_success");
            } else {
                response.sendRedirect("group_detail.jsp?id=" + groupId + "&msg=add_fail");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("group_detail.jsp?msg=invalid_group");
        }
    }
}