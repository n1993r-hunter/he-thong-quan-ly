package controller;

import java.io.IOException;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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

     // ... (Đoạn code trên: User user = dao.checkLogin(username, password); ) ...

        if (user != null) {
            // 1. Đăng nhập thành công -> Lưu Session (để dùng luôn)
            HttpSession session = request.getSession();
            session.setAttribute("loginedUser", user);

         // 2. XỬ LÝ CHỨC NĂNG GHI NHỚ ĐĂNG NHẬP
            String remember = request.getParameter("remember");
            
            // Khai báo rõ ràng 2 biến để lấy dữ liệu người dùng vừa nhập
            u = request.getParameter("username");
            p = request.getParameter("password");
            
            // Tạo 2 cái hộp Cookie nhét u và p vào
            Cookie cUser = new Cookie("cUser", u);
            Cookie cPass = new Cookie("cPass", p);
            
            if (remember != null) {
                cUser.setMaxAge(7 * 24 * 60 * 60);
                cPass.setMaxAge(7 * 24 * 60 * 60);
            } else {
                cUser.setMaxAge(0);
                cPass.setMaxAge(0);
            }
            
            response.addCookie(cUser);
            response.addCookie(cPass);

            // 3. Đá sang trang chủ
            response.sendRedirect("index.jsp");
         }  
         else {
            // 3b. NẾU SAI: Báo lỗi và bắt đăng nhập lại
            request.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            request.setAttribute("oldUsername", u);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}