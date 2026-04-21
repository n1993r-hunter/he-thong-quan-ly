package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import dao.UserDAO;
import model.User;

// Đường dẫn mà form login.jsp sẽ gọi đến
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Lấy Username và Password từ giao diện (login.jsp) gửi lên
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        // 2. Gọi DAO xuống Database để kiểm tra
        UserDAO dao = new UserDAO();
        User user = dao.checkLogin(u, p);

        if (user != null) {
            // 3a. NẾU ĐÚNG: Lưu thông tin người dùng vào Session (phiên làm việc)
            HttpSession session = request.getSession();
            session.setAttribute("loginedUser", user);
            
            // Chuyển hướng sang Trang chủ
            response.sendRedirect("index.jsp");
        } else {
            // 3b. NẾU SAI: Báo lỗi và bắt đăng nhập lại
            request.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}