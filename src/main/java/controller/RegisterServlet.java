package controller;

// 1. Import thư viện của Tomcat (Servlet)
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// 2. Import các file do nhóm mình tự viết
import dao.UserDAO;
import model.User;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Cấu hình tiếng Việt để không bị lỗi font khi nhập tên
        request.setCharacterEncoding("UTF-8");
        
        // 1. Lấy thông tin từ Form (register.jsp)
        String name = request.getParameter("fullName");
        String email = request.getParameter("email");
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        // 2. Đóng gói vào Object User
        User newUser = new User(0, name, email, user, pass);

        // 3. Gọi DAO lưu xuống Database
        UserDAO dao = new UserDAO();
        if (dao.registerUser(newUser)) {
            // Đăng ký thành công -> Phát tín hiệu "success" về login.jsp
            response.sendRedirect("login.jsp?msg=success");
        }
        else {
            // Thất bại -> Quay lại trang Đăng ký
            response.sendRedirect("register.jsp?msg=fail");
        }
    }
}