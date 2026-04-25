package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Đăng xuất thường dùng GET (khi người dùng bấm vào 1 đường link)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Lấy session hiện tại ra
        HttpSession session = request.getSession();
        
        // 2. Tiêu hủy toàn bộ dữ liệu trong session (Xóa loginedUser)
        session.invalidate();
        
        // 3. Đá người dùng về lại trang Đăng nhập
        response.sendRedirect("login.jsp");
    }
}