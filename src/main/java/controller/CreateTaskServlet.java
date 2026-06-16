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

@WebServlet("/CreateTaskServlet")
public class CreateTaskServlet extends HttpServlet {
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
            int groupId = Integer.parseInt(request.getParameter("groupId"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            
            // Mẹo: HTML5 thẻ <input type="datetime-local"> thường trả về dạng 'YYYY-MM-DDTHH:MM'
            // MySQL cần 'YYYY-MM-DD HH:MM:SS', nên ta replace chữ 'T' thành dấu cách.
            String deadlineRaw = request.getParameter("deadline");
            String deadline = deadlineRaw != null ? deadlineRaw.replace("T", " ") + ":00" : null;

            // 3. Gọi DAO xử lý
            TaskDAO dao = new TaskDAO();
            boolean isSuccess = dao.createTask(groupId, title, description, currentUser.getUserId(), deadline);

            // 4. Trả kết quả về Frontend
            if (isSuccess) {
            	dao.ActivityLogDAO logDao = new dao.ActivityLogDAO();
                logDao.logActivity(currentUser.getUserId(), groupId, null, "CREATED_TASK");
                response.sendRedirect("group_detail.jsp?id=" + groupId + "&msg=task_created");
            } else {
                response.sendRedirect("group_detail.jsp?id=" + groupId + "&msg=task_fail");
            }
        } catch (Exception e) {
            // Lỗi khi parse số hoặc thiếu dữ liệu
            response.sendRedirect("index.jsp?msg=invalid_data");
        }
    }
}