package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import dao.TaskDAO;
import model.User;

@WebServlet("/AddCommentServlet")
public class AddCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // 1. Bảo mật: Bắt buộc đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Nhận dữ liệu từ Frontend
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            String content = request.getParameter("content");

            // Chặn bình luận rỗng
            if (content == null || content.trim().isEmpty()) {
                 response.sendRedirect("task_detail.jsp?taskId=" + taskId + "&msg=empty_comment");
                 return;
            }

            // 3. Gọi DAO xử lý
            TaskDAO dao = new TaskDAO();
            boolean isSuccess = dao.addTaskComment(taskId, currentUser.getUserId(), content);

            // 4. Trả kết quả về Frontend
            if (isSuccess) {
                response.sendRedirect("task_detail.jsp?taskId=" + taskId + "&msg=comment_added");
            } else {
                response.sendRedirect("task_detail.jsp?taskId=" + taskId + "&msg=comment_fail");
            }
        } catch (Exception e) {
            response.sendRedirect("index.jsp?msg=invalid_data");
        }
    }
}