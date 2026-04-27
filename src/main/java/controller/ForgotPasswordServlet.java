package controller;

import java.io.IOException;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Tránh lỗi font
        request.setCharacterEncoding("UTF-8");
        
        // 1. Lấy dữ liệu từ form Quên mật khẩu
        String email = request.getParameter("email");
        String newPass = request.getParameter("newPassword");
        
        UserDAO dao = new UserDAO();
        
        // 2. Thực hiện cập nhật
        if (dao.updatePasswordByEmail(email, newPass)) {
            // Thành công: Đá về trang login với mã reset_success
            response.sendRedirect("login.jsp?msg=reset_success");
        } else {
            // Thất bại (Email không tồn tại): Đá về lại với mã email_not_found
            response.sendRedirect("login.jsp?msg=email_not_found");
        }
    }
}